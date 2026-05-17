import 'package:json_annotation/json_annotation.dart';

import 'location_model.dart';

part 'driver_model.g.dart';

@JsonSerializable()
class DriverModel {
  final String id;
  final String name;
  final String? avatar;
  final String phone;
  final double rating;
  final int totalRides;
  final VehicleModel vehicle;
  final LocationModel? currentLocation;

  const DriverModel({
    required this.id,
    required this.name,
    this.avatar,
    required this.phone,
    required this.rating,
    required this.totalRides,
    required this.vehicle,
    this.currentLocation,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) =>
      _$DriverModelFromJson(json);

  Map<String, dynamic> toJson() => _$DriverModelToJson(this);
}

@JsonSerializable()
class VehicleModel {
  final String plate;
  final String model;
  final String color;
  final String type;

  const VehicleModel({
    required this.plate,
    required this.model,
    required this.color,
    required this.type,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleModelToJson(this);
}
