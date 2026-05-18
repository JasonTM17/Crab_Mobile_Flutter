import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/ride_models.dart';

class RideRepository {
  final Dio dio;
  RideRepository({required this.dio});

  Future<List<FareEstimate>> estimateAllTypes({
    required GeoPoint pickup,
    required GeoPoint dropoff,
  }) async {
    final response = await dio.post('${ApiConstants.rides}/estimate', data: {
      'pickup_lat': pickup.latitude,
      'pickup_lng': pickup.longitude,
      'dropoff_lat': dropoff.latitude,
      'dropoff_lng': dropoff.longitude,
    });
    final raw = response.data;
    if (raw is List) {
      return raw.map((e) => FareEstimate.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [FareEstimate.fromJson(raw as Map<String, dynamic>)];
  }

  Future<Ride> bookRide({
    required String riderId,
    required GeoPoint pickup,
    required GeoPoint dropoff,
    required VehicleType vehicleType,
    String paymentMethod = 'WALLET',
  }) async {
    final response = await dio.post(ApiConstants.rides, data: {
      'rider_id': riderId,
      'pickup_lat': pickup.latitude,
      'pickup_lng': pickup.longitude,
      'pickup_address': pickup.address ?? '',
      'dropoff_lat': dropoff.latitude,
      'dropoff_lng': dropoff.longitude,
      'dropoff_address': dropoff.address ?? '',
      'vehicle_type': vehicleType.apiValue,
      'payment_method': paymentMethod,
    });
    return Ride.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Ride> getRide(String id) async {
    final response = await dio.get('${ApiConstants.rides}/$id');
    return Ride.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Ride>> getMyRides(String riderId) async {
    final response = await dio.get('${ApiConstants.rides}/rider/$riderId');
    final list = response.data as List;
    return list.map((e) => Ride.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Ride?> getActiveRide(String riderId) async {
    try {
      final response = await dio.get('${ApiConstants.rides}/active/rider/$riderId');
      if (response.data == null) return null;
      return Ride.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<Ride> cancelRide(String id, {String? reason}) async {
    final response = await dio.post('${ApiConstants.rides}/$id/cancel', data: {
      if (reason != null) 'reason': reason,
    });
    return Ride.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> triggerSos(String id, {double? lat, double? lng}) async {
    await dio.post('${ApiConstants.rides}/$id/sos', data: {
      if (lat != null) 'latitude': lat,
      if (lng != null) 'longitude': lng,
    });
  }
}
