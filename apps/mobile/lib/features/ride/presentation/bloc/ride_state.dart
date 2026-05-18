import 'package:equatable/equatable.dart';

import '../../data/models/driver_model.dart';
import '../../data/models/location_model.dart';
import '../../data/models/ride_model.dart';

abstract class RideState extends Equatable {
  const RideState();

  @override
  List<Object?> get props => [];
}

class RideIdle extends RideState {
  final LocationModel? pickup;
  final LocationModel? dropoff;
  final FareEstimate? fareEstimate;

  const RideIdle({this.pickup, this.dropoff, this.fareEstimate});

  @override
  List<Object?> get props => [pickup, dropoff, fareEstimate];

  RideIdle copyWith({
    LocationModel? pickup,
    LocationModel? dropoff,
    FareEstimate? fareEstimate,
  }) {
    return RideIdle(
      pickup: pickup ?? this.pickup,
      dropoff: dropoff ?? this.dropoff,
      fareEstimate: fareEstimate ?? this.fareEstimate,
    );
  }
}

class RideLoading extends RideState {
  const RideLoading();
}

class RideSearchingDriver extends RideState {
  final RideModel ride;

  const RideSearchingDriver({required this.ride});

  @override
  List<Object?> get props => [ride];
}

class RideDriverMatched extends RideState {
  final RideModel ride;
  final DriverModel driver;

  const RideDriverMatched({required this.ride, required this.driver});

  @override
  List<Object?> get props => [ride, driver];
}

class RidePickup extends RideState {
  final RideModel ride;
  final DriverModel driver;
  final int etaMinutes;
  final LocationModel? driverLocation;

  const RidePickup({
    required this.ride,
    required this.driver,
    required this.etaMinutes,
    this.driverLocation,
  });

  @override
  List<Object?> get props => [ride, driver, etaMinutes, driverLocation];
}

class RideInProgress extends RideState {
  final RideModel ride;
  final DriverModel driver;
  final LocationModel? driverLocation;

  const RideInProgress({
    required this.ride,
    required this.driver,
    this.driverLocation,
  });

  @override
  List<Object?> get props => [ride, driver, driverLocation];
}

class RideCompletedState extends RideState {
  final RideSummary summary;

  const RideCompletedState({required this.summary});

  @override
  List<Object?> get props => [summary];
}

class RideError extends RideState {
  final String message;

  const RideError({required this.message});

  @override
  List<Object?> get props => [message];
}
