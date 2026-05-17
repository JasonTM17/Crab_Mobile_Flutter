import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/location_model.dart';
import '../models/ride_model.dart';

@singleton
class RideRepository {
  final DioClient _dioClient;

  RideRepository(this._dioClient);

  Future<RideModel> createRide({
    required LocationModel pickup,
    required LocationModel dropoff,
  }) async {
    final response = await _dioClient.dio.post(
      ApiConstants.createRide,
      data: {
        'pickup': pickup.toJson(),
        'dropoff': dropoff.toJson(),
      },
    );
    return RideModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> cancelRide(String rideId) async {
    await _dioClient.dio.post(
      '${ApiConstants.rides}/$rideId/cancel',
    );
  }

  Future<FareEstimate> estimateFare({
    required LocationModel pickup,
    required LocationModel dropoff,
  }) async {
    final response = await _dioClient.dio.post(
      ApiConstants.estimateFare,
      data: {
        'pickup': pickup.toJson(),
        'dropoff': dropoff.toJson(),
      },
    );
    return FareEstimate.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<RideModel>> getRideHistory() async {
    final response = await _dioClient.dio.get(ApiConstants.rideHistory);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => RideModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RideModel?> getActiveRide() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.activeRide);
      if (response.data == null) return null;
      return RideModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
