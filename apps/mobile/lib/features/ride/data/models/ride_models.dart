class GeoPoint {
  final double latitude;
  final double longitude;
  final String? address;
  GeoPoint({required this.latitude, required this.longitude, this.address});

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        if (address != null) 'address': address,
      };

  factory GeoPoint.fromJson(Map<String, dynamic> json) => GeoPoint(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        address: json['address'] as String?,
      );
}

enum VehicleType { bike, car4, car7, premium }

extension VehicleTypeX on VehicleType {
  String get apiValue {
    switch (this) {
      case VehicleType.bike:
        return 'BIKE';
      case VehicleType.car4:
        return 'CAR_4';
      case VehicleType.car7:
        return 'CAR_7';
      case VehicleType.premium:
        return 'PREMIUM';
    }
  }

  String get label {
    switch (this) {
      case VehicleType.bike:
        return 'Bike';
      case VehicleType.car4:
        return 'Car 4-seat';
      case VehicleType.car7:
        return 'Car 7-seat';
      case VehicleType.premium:
        return 'Premium';
    }
  }

  String get icon {
    switch (this) {
      case VehicleType.bike:
        return 'motorcycle';
      case VehicleType.car4:
        return 'directions_car';
      case VehicleType.car7:
        return 'airport_shuttle';
      case VehicleType.premium:
        return 'car_rental';
    }
  }
}

class FareEstimate {
  final VehicleType vehicleType;
  final double distanceKm;
  final int durationMin;
  final int totalFare;
  final double surgeMultiplier;

  FareEstimate({
    required this.vehicleType,
    required this.distanceKm,
    required this.durationMin,
    required this.totalFare,
    required this.surgeMultiplier,
  });

  factory FareEstimate.fromJson(Map<String, dynamic> json) {
    final vt = json['vehicleType'] as String? ?? 'BIKE';
    return FareEstimate(
      vehicleType: VehicleType.values.firstWhere(
        (e) => e.apiValue == vt,
        orElse: () => VehicleType.bike,
      ),
      distanceKm: (json['distance_km'] as num? ?? 0).toDouble(),
      durationMin: (json['duration_min'] as num? ?? 0).toInt(),
      totalFare: (json['total_fare'] as num? ?? 0).toInt(),
      surgeMultiplier: (json['surge_multiplier'] as num? ?? 1).toDouble(),
    );
  }
}

enum RideStatus { requested, matched, pickup, inProgress, completed, cancelled }

extension RideStatusX on RideStatus {
  static RideStatus fromString(String s) {
    switch (s) {
      case 'REQUESTED':
        return RideStatus.requested;
      case 'MATCHED':
        return RideStatus.matched;
      case 'PICKUP':
        return RideStatus.pickup;
      case 'IN_PROGRESS':
        return RideStatus.inProgress;
      case 'COMPLETED':
        return RideStatus.completed;
      case 'CANCELLED':
        return RideStatus.cancelled;
      default:
        return RideStatus.requested;
    }
  }

  String get label {
    switch (this) {
      case RideStatus.requested:
        return 'Finding driver...';
      case RideStatus.matched:
        return 'Driver assigned';
      case RideStatus.pickup:
        return 'Driver arriving';
      case RideStatus.inProgress:
        return 'On the way';
      case RideStatus.completed:
        return 'Completed';
      case RideStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class Ride {
  final String id;
  final String riderId;
  final String? driverId;
  final RideStatus status;
  final GeoPoint pickup;
  final GeoPoint dropoff;
  final int fare;
  final double distanceKm;
  final int durationMin;
  final String vehicleType;
  final DateTime createdAt;

  Ride({
    required this.id,
    required this.riderId,
    this.driverId,
    required this.status,
    required this.pickup,
    required this.dropoff,
    required this.fare,
    required this.distanceKm,
    required this.durationMin,
    required this.vehicleType,
    required this.createdAt,
  });

  factory Ride.fromJson(Map<String, dynamic> json) => Ride(
        id: json['id'] as String,
        riderId: json['rider_id'] as String,
        driverId: json['driver_id'] as String?,
        status:
            RideStatusX.fromString(json['status'] as String? ?? 'REQUESTED'),
        pickup: GeoPoint(
          latitude: (json['pickup_lat'] as num).toDouble(),
          longitude: (json['pickup_lng'] as num).toDouble(),
          address: json['pickup_address'] as String?,
        ),
        dropoff: GeoPoint(
          latitude: (json['dropoff_lat'] as num).toDouble(),
          longitude: (json['dropoff_lng'] as num).toDouble(),
          address: json['dropoff_address'] as String?,
        ),
        fare: (json['fare'] as num? ?? 0).toInt(),
        distanceKm: (json['distance_km'] as num? ?? 0).toDouble(),
        durationMin: (json['duration_min'] as num? ?? 0).toInt(),
        vehicleType: json['vehicle_type'] as String? ?? 'BIKE',
        createdAt: DateTime.parse(
            json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      );
}
