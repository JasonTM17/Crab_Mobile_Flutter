import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/services/auth_storage.dart';
import '../models/menu_item_model.dart';
import '../models/order_model.dart';
import '../models/restaurant_model.dart';

@singleton
class FoodRepository {
  final DioClient _dioClient;
  final AuthStorage _authStorage;

  FoodRepository(this._dioClient, this._authStorage);

  Future<List<RestaurantModel>> getRestaurants({String? category}) async {
    final response = await _dioClient.dio.get(
      '${ApiConstants.restaurants}/search',
      queryParameters: category != null ? {'cuisineType': category} : null,
    );
    final list = _readList(response.data);
    return list
        .map((e) => RestaurantModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RestaurantModel> getRestaurant(String id) async {
    final response = await _dioClient.dio.get(
      '${ApiConstants.restaurants}/$id',
    );
    return RestaurantModel.fromJson(_readMap(response.data));
  }

  Future<List<MenuItemModel>> getMenu(String restaurantId) async {
    final response = await _dioClient.dio.get(
      '${ApiConstants.menus}/items/restaurant/$restaurantId',
    );
    final list = _readList(response.data);
    return list
        .map((e) => MenuItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OrderModel> placeOrder({
    required String restaurantId,
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    double deliveryLat = 10.7769,
    double deliveryLng = 106.7009,
  }) async {
    final customerId = await _requireUserId();
    final response = await _dioClient.dio.post(
      ApiConstants.orders,
      data: {
        'customerId': customerId,
        'restaurantId': restaurantId,
        'items': items,
        'deliveryLat': deliveryLat,
        'deliveryLng': deliveryLng,
        'deliveryAddress': deliveryAddress,
      },
    );
    return OrderModel.fromJson(_readMap(response.data));
  }

  Future<OrderModel> getOrder(String orderId) async {
    final response = await _dioClient.dio.get(
      '${ApiConstants.orders}/$orderId',
    );
    return OrderModel.fromJson(_readMap(response.data));
  }

  Future<List<OrderModel>> getOrderHistory() async {
    final customerId = await _requireUserId();
    final response = await _dioClient.dio.get(
      '${ApiConstants.orders}/customer/$customerId',
    );
    final list = _readList(response.data);
    return list
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OrderModel?> getActiveOrder() async {
    try {
      final customerId = await _requireUserId();
      final response = await _dioClient.dio.get(
        '${ApiConstants.orders}/customer/$customerId/active',
      );
      if (response.data == null) return null;
      final list = _readList(response.data);
      if (list.isEmpty) return null;
      return OrderModel.fromJson(list.first as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    await _dioClient.dio.put(
      '${ApiConstants.orders}/$orderId/status',
      data: {'status': 'CANCELLED', 'reason': 'Customer cancelled'},
    );
  }

  Future<String> _requireUserId() async {
    final userId = await _authStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      throw StateError('Please sign in again before placing an order.');
    }
    return userId;
  }

  List<dynamic> _readList(Object? payload) {
    if (payload is List<dynamic>) return payload;
    if (payload is Map<String, dynamic> && payload['data'] is List<dynamic>) {
      return payload['data'] as List<dynamic>;
    }
    return const [];
  }

  Map<String, dynamic> _readMap(Object? payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) return data;
      return payload;
    }
    throw StateError('Unexpected response from food service.');
  }
}
