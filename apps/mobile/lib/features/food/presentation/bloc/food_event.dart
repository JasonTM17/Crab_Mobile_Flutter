import 'package:equatable/equatable.dart';

import '../../data/models/menu_item_model.dart';
import '../../data/models/restaurant_model.dart';

abstract class FoodEvent extends Equatable {
  const FoodEvent();

  @override
  List<Object?> get props => [];
}

class LoadRestaurants extends FoodEvent {
  final String? category;

  const LoadRestaurants({this.category});

  @override
  List<Object?> get props => [category];
}

class LoadRestaurantMenu extends FoodEvent {
  final RestaurantModel restaurant;

  const LoadRestaurantMenu({required this.restaurant});

  @override
  List<Object?> get props => [restaurant];
}

class AddToCart extends FoodEvent {
  final MenuItemModel item;

  const AddToCart({required this.item});

  @override
  List<Object?> get props => [item];
}

class RemoveFromCart extends FoodEvent {
  final String itemId;

  const RemoveFromCart({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

class ClearCart extends FoodEvent {
  const ClearCart();
}

class PlaceOrder extends FoodEvent {
  final String deliveryAddress;

  const PlaceOrder({required this.deliveryAddress});

  @override
  List<Object?> get props => [deliveryAddress];
}

class LoadOrderHistory extends FoodEvent {
  const LoadOrderHistory();
}

class LoadOrder extends FoodEvent {
  final String orderId;

  const LoadOrder({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class LoadActiveOrder extends FoodEvent {
  const LoadActiveOrder();
}

class OrderStatusUpdated extends FoodEvent {
  final String orderId;
  final String status;
  final int? estimatedMinutes;

  const OrderStatusUpdated({
    required this.orderId,
    required this.status,
    this.estimatedMinutes,
  });

  @override
  List<Object?> get props => [orderId, status, estimatedMinutes];
}

class CancelOrder extends FoodEvent {
  final String orderId;

  const CancelOrder({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class FilterCategoryChanged extends FoodEvent {
  final String? category;

  const FilterCategoryChanged({this.category});

  @override
  List<Object?> get props => [category];
}
