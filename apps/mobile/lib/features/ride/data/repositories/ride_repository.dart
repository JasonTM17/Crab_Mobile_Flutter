import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../shared/services/auth_storage.dart';
import '../models/location_model.dart' as loc;
import '../models/ride_model.dart';
import '../models/ride_models.dart' as legacy;

class RideRepository {
  final Dio dio;
  final AuthStorage _authStorage;

  RideRepository({required this.dio, required AuthStorage authStorage})
      : _authStorage = authStorage;

  Future<loc.FareEstimate> estimateFare({
    required loc.LocationModel pickup,
    required loc.LocationModel dropoff,
  }) async {
    final response = await dio.post(
      '${ApiConstants.rides}/estimate',
      data: {
        'pickup_lat': pickup.latitude,
        'pickup_lng': pickup.longitude,
        'dropoff_lat': dropoff.latitude,
        'dropoff_lng': dropoff.longitude,
      },
    );

    final raw = _readPayload(response.data);
    if (raw is! List || raw.isEmpty) {
      throw Exception('No fare estimate returned');
    }

    final list = raw;
    final fares = list.map((e) => (e['total_fare'] as num).toDouble()).toList();
    final minFare = fares.reduce((a, b) => a < b ? a : b);
    final maxFare = fares.reduce((a, b) => a > b ? a : b);

    final first = list.first;
    final distanceKm = (first['distance_km'] as num).toDouble();
    final estimatedMinutes = (first['duration_min'] as num).toInt();

    return loc.FareEstimate(
      minFare: minFare,
      maxFare: maxFare,
      distanceKm: distanceKm,
      estimatedMinutes: estimatedMinutes,
      currency: 'VND',
    );
  }

  Future<RideModel> createRide({
    required loc.LocationModel pickup,
    required loc.LocationModel dropoff,
  }) async {
    final riderId = await _requireUserId();
    final response = await dio.post(
      ApiConstants.rides,
      data: {
        'rider_id': riderId,
        'pickup_lat': pickup.latitude,
        'pickup_lng': pickup.longitude,
        'pickup_address': pickup.name ?? pickup.address ?? '',
        'dropoff_lat': dropoff.latitude,
        'dropoff_lng': dropoff.longitude,
        'dropoff_address': dropoff.name ?? dropoff.address ?? '',
      },
    );

    return RideModel.fromBackendJson(_readMap(response.data));
  }

  Future<legacy.Ride> getRide(String id) async {
    final response = await dio.get('${ApiConstants.rides}/$id');
    return legacy.Ride.fromJson(_readMap(response.data));
  }

  Future<List<legacy.Ride>> getMyRides(String riderId) async {
    final response = await dio.get('${ApiConstants.rides}/rider/$riderId');
    final raw = _readPayload(response.data);
    final list = raw is List<dynamic> ? raw : const <dynamic>[];
    return list
        .map((e) => legacy.Ride.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<legacy.Ride?> getActiveRide(String riderId) async {
    try {
      final response =
          await dio.get('${ApiConstants.rides}/active/rider/$riderId');
      if (response.data == null) return null;
      return legacy.Ride.fromJson(_readMap(response.data));
    } catch (_) {
      return null;
    }
  }

  Future<void> cancelRide(String rideId, {String? reason}) async {
    await dio.post(
      '${ApiConstants.rides}/$rideId/cancel',
      data: {'reason': reason ?? 'User cancelled'},
    );
  }

  Future<void> triggerSos(String rideId, {double? lat, double? lng}) async {
    await dio.post(
      '${ApiConstants.rides}/$rideId/sos',
      data: {
        if (lat != null) 'latitude': lat,
        if (lng != null) 'longitude': lng,
      },
    );
  }

  Future<String> _requireUserId() async {
    final userId = await _authStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      throw StateError('Please sign in again before requesting a ride.');
    }
    return userId;
  }

  Object? _readPayload(Object? payload) {
    if (payload is Map<String, dynamic> && payload.containsKey('data')) {
      return payload['data'];
    }
    return payload;
  }

  Map<String, dynamic> _readMap(Object? payload) {
    final data = _readPayload(payload);
    if (data is Map<String, dynamic>) return data;
    throw StateError('Unexpected response from ride service.');
  }
}
