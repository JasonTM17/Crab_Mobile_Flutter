import 'package:equatable/equatable.dart';

abstract class DriverEvent extends Equatable {
  const DriverEvent();

  @override
  List<Object?> get props => [];
}

class GoOnline extends DriverEvent {
  const GoOnline();
}

class GoOffline extends DriverEvent {
  const GoOffline();
}

class RideRequestReceived extends DriverEvent {
  final Map<String, dynamic> rideRequestData;

  const RideRequestReceived({required this.rideRequestData});

  @override
  List<Object?> get props => [rideRequestData];
}

class AcceptRide extends DriverEvent {
  final String rideId;

  const AcceptRide({required this.rideId});

  @override
  List<Object?> get props => [rideId];
}

class RejectRide extends DriverEvent {
  final String rideId;

  const RejectRide({required this.rideId});

  @override
  List<Object?> get props => [rideId];
}

class StartRide extends DriverEvent {
  final String rideId;

  const StartRide({required this.rideId});

  @override
  List<Object?> get props => [rideId];
}

class CompleteRide extends DriverEvent {
  final String rideId;

  const CompleteRide({required this.rideId});

  @override
  List<Object?> get props => [rideId];
}

class UpdateLocation extends DriverEvent {
  final double latitude;
  final double longitude;

  const UpdateLocation({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

class CountdownTick extends DriverEvent {
  final int remaining;

  const CountdownTick({required this.remaining});

  @override
  List<Object?> get props => [remaining];
}

class ToggleAutoAccept extends DriverEvent {
  const ToggleAutoAccept();
}
