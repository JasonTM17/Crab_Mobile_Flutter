import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/driver_model.dart';
import '../../data/models/location_model.dart';
import '../../data/models/ride_model.dart';
import '../../data/repositories/ride_repository.dart';
import 'ride_event.dart';
import 'ride_state.dart';

@injectable
class RideBloc extends Bloc<RideEvent, RideState> {
  final RideRepository _rideRepository;

  RideBloc(this._rideRepository) : super(const RideIdle()) {
    on<PickupLocationSelected>(_onPickupSelected);
    on<DropoffLocationSelected>(_onDropoffSelected);
    on<EstimateFareRequested>(_onEstimateFare);
    on<RequestRide>(_onRequestRide);
    on<CancelRide>(_onCancelRide);
    on<DriverMatched>(_onDriverMatched);
    on<LocationUpdate>(_onLocationUpdate);
    on<RideStatusChanged>(_onRideStatusChanged);
    on<RideCompleted>(_onRideCompleted);
  }

  void _onPickupSelected(
    PickupLocationSelected event,
    Emitter<RideState> emit,
  ) {
    final current = state is RideIdle ? state as RideIdle : const RideIdle();
    emit(current.copyWith(pickup: event.location));
  }

  void _onDropoffSelected(
    DropoffLocationSelected event,
    Emitter<RideState> emit,
  ) {
    final current = state is RideIdle ? state as RideIdle : const RideIdle();
    emit(current.copyWith(dropoff: event.location));
  }

  Future<void> _onEstimateFare(
    EstimateFareRequested event,
    Emitter<RideState> emit,
  ) async {
    try {
      final estimate = await _rideRepository.estimateFare(
        pickup: event.pickup,
        dropoff: event.dropoff,
      );
      final current =
          state is RideIdle ? state as RideIdle : const RideIdle();
      emit(current.copyWith(
        pickup: event.pickup,
        dropoff: event.dropoff,
        fareEstimate: estimate,
      ));
    } catch (e) {
      emit(RideError(message: _parseError(e)));
    }
  }

  Future<void> _onRequestRide(
    RequestRide event,
    Emitter<RideState> emit,
  ) async {
    emit(const RideLoading());
    try {
      final ride = await _rideRepository.createRide(
        pickup: event.pickup,
        dropoff: event.dropoff,
      );
      emit(RideSearchingDriver(ride: ride));
    } catch (e) {
      emit(RideError(message: _parseError(e)));
    }
  }

  Future<void> _onCancelRide(
    CancelRide event,
    Emitter<RideState> emit,
  ) async {
    try {
      await _rideRepository.cancelRide(event.rideId);
      emit(const RideIdle());
    } catch (e) {
      emit(RideError(message: _parseError(e)));
    }
  }

  void _onDriverMatched(
    DriverMatched event,
    Emitter<RideState> emit,
  ) {
    if (state is RideSearchingDriver) {
      final current = state as RideSearchingDriver;
      final driver = DriverModel.fromJson(event.driverData);
      emit(RideDriverMatched(ride: current.ride, driver: driver));
    }
  }

  void _onLocationUpdate(
    LocationUpdate event,
    Emitter<RideState> emit,
  ) {
    final driverLocation = LocationModel(
      latitude: event.latitude,
      longitude: event.longitude,
    );

    if (state is RidePickup) {
      final current = state as RidePickup;
      emit(RidePickup(
        ride: current.ride,
        driver: current.driver,
        etaMinutes: current.etaMinutes,
        driverLocation: driverLocation,
      ));
    } else if (state is RideInProgress) {
      final current = state as RideInProgress;
      emit(RideInProgress(
        ride: current.ride,
        driver: current.driver,
        driverLocation: driverLocation,
      ));
    }
  }

  void _onRideStatusChanged(
    RideStatusChanged event,
    Emitter<RideState> emit,
  ) {
    switch (event.status) {
      case 'pickup':
        if (state is RideDriverMatched) {
          final current = state as RideDriverMatched;
          emit(RidePickup(
            ride: current.ride,
            driver: current.driver,
            etaMinutes: (event.extra?['etaMinutes'] as num?)?.toInt() ?? 5,
          ));
        }
      case 'in_progress':
        if (state is RidePickup) {
          final current = state as RidePickup;
          emit(RideInProgress(
            ride: current.ride,
            driver: current.driver,
          ));
        }
      case 'cancelled':
        emit(const RideIdle());
    }
  }

  void _onRideCompleted(
    RideCompleted event,
    Emitter<RideState> emit,
  ) {
    final summary = RideSummary.fromJson(event.summaryData);
    emit(RideCompletedState(summary: summary));
  }

  String _parseError(Object e) {
    return e.toString().replaceAll('Exception: ', '');
  }
}
