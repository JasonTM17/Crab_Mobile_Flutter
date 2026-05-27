import 'package:equatable/equatable.dart';

import '../../data/models/location_model.dart';

abstract class RideEvent extends Equatable {
  const RideEvent();

  @override
  List<Object?> get props => [];
}

class RequestRide extends RideEvent {
  final LocationModel pickup;
  final LocationModel dropoff;
  final String vehicleType;

  const RequestRide({
    required this.pickup,
    required this.dropoff,
    this.vehicleType = 'BIKE',
  });

  @override
  List<Object?> get props => [pickup, dropoff, vehicleType];
}

class CancelRide extends RideEvent {
  final String rideId;

  const CancelRide({required this.rideId});

  @override
  List<Object?> get props => [rideId];
}

class DriverMatched extends RideEvent {
  final Map<String, dynamic> driverData;

  const DriverMatched({required this.driverData});

  @override
  List<Object?> get props => [driverData];
}

class LocationUpdate extends RideEvent {
  final double latitude;
  final double longitude;

  const LocationUpdate({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

class RideStatusChanged extends RideEvent {
  final String status;
  final Map<String, dynamic>? extra;

  const RideStatusChanged({required this.status, this.extra});

  @override
  List<Object?> get props => [status, extra];
}

class RideCompleted extends RideEvent {
  final Map<String, dynamic> summaryData;

  const RideCompleted({required this.summaryData});

  @override
  List<Object?> get props => [summaryData];
}

class EstimateFareRequested extends RideEvent {
  final LocationModel pickup;
  final LocationModel dropoff;

  const EstimateFareRequested({required this.pickup, required this.dropoff});

  @override
  List<Object?> get props => [pickup, dropoff];
}

class PickupLocationSelected extends RideEvent {
  final LocationModel location;

  const PickupLocationSelected({required this.location});

  @override
  List<Object?> get props => [location];
}

class DropoffLocationSelected extends RideEvent {
  final LocationModel location;

  const DropoffLocationSelected({required this.location});

  @override
  List<Object?> get props => [location];
}
