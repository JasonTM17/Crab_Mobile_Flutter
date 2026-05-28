import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/repositories/driver_repository.dart';
import '../../../../../shared/utils/error_message.dart';
import 'driver_event.dart';
import 'driver_state.dart';

@injectable
class DriverBloc extends Bloc<DriverEvent, DriverState> {
  final DriverRepository _driverRepository;
  Timer? _countdownTimer;
  Timer? _locationTimer;
  int _locationSampleIndex = 0;

  static const int _countdownSeconds = 15;
  static const List<_DriverLocationSample> _demoRouteSamples = [
    _DriverLocationSample(latitude: 10.7769, longitude: 106.7009),
    _DriverLocationSample(latitude: 10.7778, longitude: 106.7024),
    _DriverLocationSample(latitude: 10.7791, longitude: 106.7042),
    _DriverLocationSample(latitude: 10.7804, longitude: 106.7061),
  ];

  DriverBloc(this._driverRepository) : super(const DriverOffline()) {
    on<GoOnline>(_onGoOnline);
    on<GoOffline>(_onGoOffline);
    on<RideRequestReceived>(_onRideRequestReceived);
    on<AcceptRide>(_onAcceptRide);
    on<RejectRide>(_onRejectRide);
    on<StartRide>(_onStartRide);
    on<CompleteRide>(_onCompleteRide);
    on<UpdateLocation>(_onUpdateLocation);
    on<CountdownTick>(_onCountdownTick);
    on<ToggleAutoAccept>(_onToggleAutoAccept);
  }

  Future<void> _onGoOnline(GoOnline event, Emitter<DriverState> emit) async {
    try {
      await _driverRepository.goOnline();
      emit(DriverOnlineIdle(isAutoAcceptEnabled: state.isAutoAcceptEnabled));
      _startLocationStreaming();
    } catch (e) {
      emit(DriverError(
        message: _parseError(e),
        isAutoAcceptEnabled: state.isAutoAcceptEnabled,
      ));
    }
  }

  Future<void> _onGoOffline(GoOffline event, Emitter<DriverState> emit) async {
    _stopLocationStreaming();
    _stopCountdown();
    try {
      await _driverRepository.goOffline();
    } catch (_) {
      // Best-effort offline
    }
    emit(DriverOffline(isAutoAcceptEnabled: state.isAutoAcceptEnabled));
  }

  void _onRideRequestReceived(
    RideRequestReceived event,
    Emitter<DriverState> emit,
  ) {
    _stopCountdown();
    final rideRequest = RideRequest.fromJson(event.rideRequestData);
    emit(DriverRideRequest(
      rideRequest: rideRequest,
      countdown: _countdownSeconds,
      isAutoAcceptEnabled: state.isAutoAcceptEnabled,
    ));
    _startCountdown(rideRequest.id);

    if (state.isAutoAcceptEnabled) {
      add(AcceptRide(rideId: rideRequest.id));
    }
  }

  Future<void> _onAcceptRide(
    AcceptRide event,
    Emitter<DriverState> emit,
  ) async {
    _stopCountdown();
    try {
      final ride = await _driverRepository.acceptRide(event.rideId);
      emit(DriverNavigatingToPickup(
        ride: ride,
        isAutoAcceptEnabled: state.isAutoAcceptEnabled,
      ));
    } catch (e) {
      emit(DriverError(
        message: _parseError(e),
        isAutoAcceptEnabled: state.isAutoAcceptEnabled,
      ));
    }
  }

  Future<void> _onRejectRide(
    RejectRide event,
    Emitter<DriverState> emit,
  ) async {
    _stopCountdown();
    try {
      await _driverRepository.rejectRide(event.rideId);
    } catch (_) {
      // Best-effort reject
    }
    emit(DriverOnlineIdle(isAutoAcceptEnabled: state.isAutoAcceptEnabled));
  }

  Future<void> _onStartRide(
    StartRide event,
    Emitter<DriverState> emit,
  ) async {
    if (state is DriverNavigatingToPickup) {
      try {
        final ride = await _driverRepository.startRide(event.rideId);
        emit(DriverInRide(
          ride: ride,
          isAutoAcceptEnabled: state.isAutoAcceptEnabled,
        ));
      } catch (e) {
        emit(DriverError(
          message: _parseError(e),
          isAutoAcceptEnabled: state.isAutoAcceptEnabled,
        ));
      }
    }
  }

  Future<void> _onCompleteRide(
    CompleteRide event,
    Emitter<DriverState> emit,
  ) async {
    if (state is DriverInRide) {
      try {
        await _driverRepository.completeRide(event.rideId);
        emit(DriverOnlineIdle(isAutoAcceptEnabled: state.isAutoAcceptEnabled));
      } catch (e) {
        emit(DriverError(
          message: _parseError(e),
          isAutoAcceptEnabled: state.isAutoAcceptEnabled,
        ));
      }
    }
  }

  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<DriverState> emit,
  ) async {
    try {
      await _driverRepository.updateLocation(
        latitude: event.latitude,
        longitude: event.longitude,
      );
    } catch (_) {
      // Non-fatal: location update failure should not disrupt state
    }
  }

  void _onCountdownTick(CountdownTick event, Emitter<DriverState> emit) {
    if (state is DriverRideRequest) {
      final current = state as DriverRideRequest;
      if (event.remaining <= 0) {
        _stopCountdown();
        // Auto-reject when countdown expires
        add(RejectRide(rideId: current.rideRequest.id));
      } else {
        emit(current.copyWith(countdown: event.remaining));
      }
    }
  }

  void _startCountdown(String rideId) {
    int remaining = _countdownSeconds;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      remaining--;
      add(CountdownTick(remaining: remaining));
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  void _startLocationStreaming() {
    _locationSampleIndex = 0;
    _locationTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      final sample =
          _demoRouteSamples[_locationSampleIndex % _demoRouteSamples.length];
      _locationSampleIndex++;
      add(UpdateLocation(
        latitude: sample.latitude,
        longitude: sample.longitude,
      ));
    });
  }

  void _stopLocationStreaming() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  String _parseError(Object e) {
    return mapErrorToMessage(e);
  }

  void _onToggleAutoAccept(ToggleAutoAccept event, Emitter<DriverState> emit) {
    final newValue = !state.isAutoAcceptEnabled;
    final currentState = state;
    if (currentState is DriverOffline) {
      emit(DriverOffline(isAutoAcceptEnabled: newValue));
    } else if (currentState is DriverOnlineIdle) {
      emit(DriverOnlineIdle(isAutoAcceptEnabled: newValue));
    } else if (currentState is DriverRideRequest) {
      emit(currentState.copyWith(isAutoAcceptEnabled: newValue));
    } else if (currentState is DriverNavigatingToPickup) {
      emit(DriverNavigatingToPickup(
          ride: currentState.ride, isAutoAcceptEnabled: newValue));
    } else if (currentState is DriverInRide) {
      emit(
          DriverInRide(ride: currentState.ride, isAutoAcceptEnabled: newValue));
    } else if (currentState is DriverError) {
      emit(DriverError(
          message: currentState.message, isAutoAcceptEnabled: newValue));
    }
  }

  @override
  Future<void> close() {
    _stopCountdown();
    _stopLocationStreaming();
    return super.close();
  }
}

class _DriverLocationSample {
  final double latitude;
  final double longitude;

  const _DriverLocationSample({
    required this.latitude,
    required this.longitude,
  });
}
