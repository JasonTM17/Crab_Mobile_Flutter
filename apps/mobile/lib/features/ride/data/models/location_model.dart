import 'package:json_annotation/json_annotation.dart';

part 'location_model.g.dart';

@JsonSerializable()
class LocationModel {
  final double latitude;
  final double longitude;
  final String? address;
  final String? name;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    this.address,
    this.name,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationModelToJson(this);
}

@JsonSerializable()
class FareEstimate {
  final double minFare;
  final double maxFare;
  final double distanceKm;
  final int estimatedMinutes;
  final String currency;

  const FareEstimate({
    required this.minFare,
    required this.maxFare,
    required this.distanceKm,
    required this.estimatedMinutes,
    this.currency = 'VND',
  });

  factory FareEstimate.fromJson(Map<String, dynamic> json) =>
      _$FareEstimateFromJson(json);

  Map<String, dynamic> toJson() => _$FareEstimateToJson(this);
}
