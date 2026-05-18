import 'package:injectable/injectable.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../data/models/ride_model.dart';

@singleton
class DriverRepository {
  final DioClient _dioClient;

  DriverRepository(this._dioClient);

  Future<void> goOnline() async {
    await _dioClient.dio.post('${ApiConstants.driverBase}/online');
  }

  Future<void> goOffline() async {
    await _dioClient.dio.post('${ApiConstants.driverBase}/offline');
  }

  Future<RideModel> acceptRide(String rideId) async {
    final response = await _dioClient.dio.post(
      '${ApiConstants.rides}/$rideId/accept',
    );
    return RideModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> rejectRide(String rideId) async {
    await _dioClient.dio.post('${ApiConstants.rides}/$rideId/reject');
  }

  Future<RideModel> startRide(String rideId) async {
    final response = await _dioClient.dio.patch(
      '${ApiConstants.rides}/$rideId/status',
      data: {'status': 'in_progress'},
    );
    return RideModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RideModel> completeRide(String rideId) async {
    final response = await _dioClient.dio.patch(
      '${ApiConstants.rides}/$rideId/status',
      data: {'status': 'completed'},
    );
    return RideModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    await _dioClient.dio.post(
      '${ApiConstants.driverBase}/location',
      data: {'latitude': latitude, 'longitude': longitude},
    );
  }
}
