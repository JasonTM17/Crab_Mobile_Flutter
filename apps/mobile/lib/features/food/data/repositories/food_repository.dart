import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/menu_item_model.dart';
import '../models/order_model.dart';
import '../models/restaurant_model.dart';

@singleton
class FoodRepository {
  final DioClient _dioClient;

  FoodRepository(this._dioClient);

  Future<List<RestaurantModel>> getRestaurants({String? category}) async {
    final response = await _dioClient.dio.get(
      ApiConstants.restaurants,
      queryParameters: category != null ? {'category': category} : null,
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => RestaurantModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RestaurantModel> getRestaurant(String id) async {
    final response =
        await _dioClient.dio.get('${ApiConstants.restaurants}/$id');
    return RestaurantModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<MenuItemModel>> getMenu(String restaurantId) async {
    final response = await _dioClient.dio
        .get('${ApiConstants.restaurants}/$restaurantId/menu');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => MenuItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OrderModel> placeOrder({
    required String restaurantId,
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
  }) async {
    final response = await _dioClient.dio.post(
      ApiConstants.orders,
      data: {
        'restaurantId': restaurantId,
        'items': items,
        'deliveryAddress': deliveryAddress,
      },
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<OrderModel>> getOrderHistory() async {
    final response = await _dioClient.dio.get(ApiConstants.orderHistory);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OrderModel?> getActiveOrder() async {
    try {
      final response =
          await _dioClient.dio.get(ApiConstants.activeOrder);
      if (response.data == null) return null;
      return OrderModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    await _dioClient.dio.post('${ApiConstants.orders}/$orderId/cancel');
  }
}
