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

  static const int _countdownSeconds = 15;

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
  }

  Future<void> _onGoOnline(GoOnline event, Emitter<DriverState> emit) async {
    try {
      await _driverRepository.goOnline();
      emit(const DriverOnlineIdle());
      _startLocationStreaming();
    } catch (e) {
      emit(DriverError(message: _parseError(e)));
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
    emit(const DriverOffline());
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
    ));
    _startCountdown(rideRequest.id);
  }

  Future<void> _onAcceptRide(
    AcceptRide event,
    Emitter<DriverState> emit,
  ) async {
    _stopCountdown();
    try {
      final ride = await _driverRepository.acceptRide(event.rideId);
      emit(DriverNavigatingToPickup(ride: ride));
    } catch (e) {
      emit(DriverError(message: _parseError(e)));
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
    emit(const DriverOnlineIdle());
  }

  Future<void> _onStartRide(
    StartRide event,
    Emitter<DriverState> emit,
  ) async {
    if (state is DriverNavigatingToPickup) {
      try {
        final ride = await _driverRepository.startRide(event.rideId);
        emit(DriverInRide(ride: ride));
      } catch (e) {
        emit(DriverError(message: _parseError(e)));
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
        emit(const DriverOnlineIdle());
      } catch (e) {
        emit(DriverError(message: _parseError(e)));
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
    // Send mock location every 2 seconds when online
    // In production, replace with geolocator stream
    _locationTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      // Mock HCMC coordinates with slight drift
      add(const UpdateLocation(
        latitude: 10.7769,
        longitude: 106.7009,
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

  @override
  Future<void> close() {
    _stopCountdown();
    _stopLocationStreaming();
    return super.close();
  }
}
