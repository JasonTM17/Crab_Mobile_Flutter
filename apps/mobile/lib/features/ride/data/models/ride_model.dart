import 'package:json_annotation/json_annotation.dart';

import 'driver_model.dart';
import 'location_model.dart';

part 'ride_model.g.dart';

enum RideStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('searching')
  searching,
  @JsonValue('driver_matched')
  driverMatched,
  @JsonValue('pickup')
  pickup,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

@JsonSerializable()
class RideModel {
  final String id;
  final LocationModel pickup;
  final LocationModel dropoff;
  final RideStatus status;
  final DriverModel? driver;
  final double? fare;
  final String currency;
  final int? etaMinutes;
  final DateTime createdAt;
  final DateTime? completedAt;

  const RideModel({
    required this.id,
    required this.pickup,
    required this.dropoff,
    required this.status,
    this.driver,
    this.fare,
    this.currency = 'VND',
    this.etaMinutes,
    required this.createdAt,
    this.completedAt,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) =>
      _$RideModelFromJson(json);

  factory RideModel.fromBackendJson(Map<String, dynamic> json) {
    final status = switch (_asString(json['status']).toUpperCase()) {
      'REQUESTED' => RideStatus.searching,
      'MATCHED' => RideStatus.driverMatched,
      'PICKUP' => RideStatus.pickup,
      'IN_PROGRESS' => RideStatus.inProgress,
      'COMPLETED' => RideStatus.completed,
      'CANCELLED' => RideStatus.cancelled,
      _ => RideStatus.pending,
    };

    return RideModel(
      id: _asString(json['id']),
      pickup: LocationModel(
        latitude: _asDouble(json['pickup_lat']),
        longitude: _asDouble(json['pickup_lng']),
        address: json['pickup_address'] as String?,
      ),
      dropoff: LocationModel(
        latitude: _asDouble(json['dropoff_lat']),
        longitude: _asDouble(json['dropoff_lng']),
        address: json['dropoff_address'] as String?,
      ),
      status: status,
      fare: _asNullableDouble(json['fare']),
      currency: json['currency'] as String? ?? 'VND',
      etaMinutes: _asNullableInt(json['duration_min'] ?? json['etaMinutes']),
      createdAt: _asDateTime(json['created_at'] ?? json['createdAt']),
      completedAt: _asNullableDateTime(
        json['completed_at'] ?? json['completedAt'],
      ),
    );
  }

  Map<String, dynamic> toJson() => _$RideModelToJson(this);
}

@JsonSerializable()
class RideSummary {
  final String rideId;
  final double fare;
  final String currency;
  final double distanceKm;
  final int durationMinutes;
  final DateTime completedAt;

  const RideSummary({
    required this.rideId,
    required this.fare,
    this.currency = 'VND',
    required this.distanceKm,
    required this.durationMinutes,
    required this.completedAt,
  });

  factory RideSummary.fromJson(Map<String, dynamic> json) =>
      _$RideSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$RideSummaryToJson(this);
}

String _asString(Object? value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString();
}

double _asDouble(Object? value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

double? _asNullableDouble(Object? value) {
  if (value == null) return null;
  return _asDouble(value);
}

int? _asNullableInt(Object? value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

DateTime _asDateTime(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}

DateTime? _asNullableDateTime(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
