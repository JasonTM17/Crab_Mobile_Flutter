import 'package:equatable/equatable.dart';

import '../../../data/models/ride_model.dart';

abstract class DriverState extends Equatable {
  final bool isAutoAcceptEnabled;

  const DriverState({this.isAutoAcceptEnabled = true});

  @override
  List<Object?> get props => [isAutoAcceptEnabled];
}

class DriverOffline extends DriverState {
  const DriverOffline({super.isAutoAcceptEnabled});
}

class DriverOnlineIdle extends DriverState {
  const DriverOnlineIdle({super.isAutoAcceptEnabled});
}

class DriverRideRequest extends DriverState {
  final RideRequest rideRequest;
  final int countdown;

  const DriverRideRequest({
    required this.rideRequest,
    required this.countdown,
    super.isAutoAcceptEnabled,
  });

  @override
  List<Object?> get props => [rideRequest, countdown, isAutoAcceptEnabled];

  DriverRideRequest copyWith({int? countdown, bool? isAutoAcceptEnabled}) {
    return DriverRideRequest(
      rideRequest: rideRequest,
      countdown: countdown ?? this.countdown,
      isAutoAcceptEnabled: isAutoAcceptEnabled ?? this.isAutoAcceptEnabled,
    );
  }
}

class DriverNavigatingToPickup extends DriverState {
  final RideModel ride;

  const DriverNavigatingToPickup({
    required this.ride,
    super.isAutoAcceptEnabled,
  });

  @override
  List<Object?> get props => [ride, isAutoAcceptEnabled];
}

class DriverInRide extends DriverState {
  final RideModel ride;

  const DriverInRide({
    required this.ride,
    super.isAutoAcceptEnabled,
  });

  @override
  List<Object?> get props => [ride, isAutoAcceptEnabled];
}

class DriverError extends DriverState {
  final String message;

  const DriverError({
    required this.message,
    super.isAutoAcceptEnabled,
  });

  @override
  List<Object?> get props => [message, isAutoAcceptEnabled];
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
