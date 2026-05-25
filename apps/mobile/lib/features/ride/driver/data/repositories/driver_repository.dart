import 'package:injectable/injectable.dart';

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../shared/services/auth_storage.dart';
import '../../../data/models/ride_model.dart';

@singleton
class DriverRepository {
  final DioClient _dioClient;
  final AuthStorage _authStorage;

  DriverRepository(this._dioClient, this._authStorage);

  Future<void> goOnline() async {
    final driverId = await _requireDriverId();
    await _dioClient.dio.post(
      '${ApiConstants.driverBase}/online',
      data: {'driverId': driverId},
    );
  }

  Future<void> goOffline() async {
    final driverId = await _requireDriverId();
    await _dioClient.dio.post(
      '${ApiConstants.driverBase}/offline',
      data: {'driverId': driverId},
    );
  }

  Future<RideModel> acceptRide(String rideId) async {
    final driverId = await _requireDriverId();
    final response = await _dioClient.dio.post(
      '${ApiConstants.rides}/$rideId/accept',
      data: {'driverId': driverId},
    );
    return RideModel.fromBackendJson(_readMap(response.data));
  }

  Future<void> rejectRide(String rideId) async {
    final driverId = await _requireDriverId();
    await _dioClient.dio.post(
      '${ApiConstants.rides}/$rideId/reject',
      data: {'driverId': driverId},
    );
  }

  Future<RideModel> startRide(String rideId) async {
    final response = await _dioClient.dio.patch(
      '${ApiConstants.rides}/$rideId/status',
      data: {'status': 'IN_PROGRESS'},
    );
    return RideModel.fromBackendJson(_readMap(response.data));
  }

  Future<RideModel> completeRide(String rideId) async {
    final response = await _dioClient.dio.patch(
      '${ApiConstants.rides}/$rideId/status',
      data: {'status': 'COMPLETED'},
    );
    return RideModel.fromBackendJson(_readMap(response.data));
  }

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final driverId = await _requireDriverId();
    await _dioClient.dio.post(
      '${ApiConstants.driverBase}/location',
      data: {
        'driverId': driverId,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  Future<String> _requireDriverId() async {
    final driverId = await _authStorage.getUserId();
    if (driverId == null || driverId.isEmpty) {
      throw StateError('Please sign in again before using driver mode.');
    }
    return driverId;
  }

  Map<String, dynamic> _readMap(Object? payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) return data;
      return payload;
    }
    throw StateError('Unexpected response from ride service.');
  }
}
