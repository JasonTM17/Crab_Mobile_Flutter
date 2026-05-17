import 'package:json_annotation/json_annotation.dart';

import 'driver_model.dart';
import 'location_model.dart';

part 'ride_model.g.dart';

enum RideStatus {
  @JsonValue('pending') pending,
  @JsonValue('searching') searching,
  @JsonValue('driver_matched') driverMatched,
  @JsonValue('pickup') pickup,
  @JsonValue('in_progress') inProgress,
  @JsonValue('completed') completed,
  @JsonValue('cancelled') cancelled,
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
