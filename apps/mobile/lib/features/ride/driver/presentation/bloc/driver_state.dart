import 'package:equatable/equatable.dart';

import '../../../data/models/ride_model.dart';

abstract class DriverState extends Equatable {
  const DriverState();

  @override
  List<Object?> get props => [];
}

class DriverOffline extends DriverState {
  const DriverOffline();
}

class DriverOnlineIdle extends DriverState {
  const DriverOnlineIdle();
}

class DriverRideRequest extends DriverState {
  final RideRequest rideRequest;
  final int countdown;

  const DriverRideRequest({
    required this.rideRequest,
    required this.countdown,
  });

  @override
  List<Object?> get props => [rideRequest, countdown];

  DriverRideRequest copyWith({int? countdown}) {
    return DriverRideRequest(
      rideRequest: rideRequest,
      countdown: countdown ?? this.countdown,
    );
  }
}

class DriverNavigatingToPickup extends DriverState {
  final RideModel ride;

  const DriverNavigatingToPickup({required this.ride});

  @override
  List<Object?> get props => [ride];
}

class DriverInRide extends DriverState {
  final RideModel ride;

  const DriverInRide({required this.ride});

  @override
  List<Object?> get props => [ride];
}

class DriverError extends DriverState {
  final String message;

  const DriverError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Lightweight ride request model received via socket
class RideRequest extends Equatable {
  final String id;
  final String pickupAddress;
  final String dropoffAddress;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final double estimatedFare;
  final double distanceKm;
  final String currency;

  const RideRequest({
    required this.id,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.estimatedFare,
    required this.distanceKm,
    this.currency = 'VND',
  });

  factory RideRequest.fromJson(Map<String, dynamic> json) {
    final pickup = json['pickup'] as Map<String, dynamic>? ?? {};
    final dropoff = json['dropoff'] as Map<String, dynamic>? ?? {};
    return RideRequest(
      id: json['id'] as String? ?? '',
      pickupAddress: pickup['address'] as String? ?? 'Unknown pickup',
      dropoffAddress: dropoff['address'] as String? ?? 'Unknown destination',
      pickupLat: (pickup['latitude'] as num?)?.toDouble() ?? 0,
      pickupLng: (pickup['longitude'] as num?)?.toDouble() ?? 0,
      dropoffLat: (dropoff['latitude'] as num?)?.toDouble() ?? 0,
      dropoffLng: (dropoff['longitude'] as num?)?.toDouble() ?? 0,
      estimatedFare: (json['estimatedFare'] as num?)?.toDouble() ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'VND',
    );
  }

  @override
  List<Object?> get props => [id];
}
