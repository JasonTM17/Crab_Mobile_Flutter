import 'package:equatable/equatable.dart';

import '../../data/models/cart_model.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/restaurant_model.dart';

abstract class FoodState extends Equatable {
  const FoodState();

  @override
  List<Object?> get props => [];
}

class FoodInitial extends FoodState {
  const FoodInitial();
}

class FoodLoading extends FoodState {
  const FoodLoading();
}

class RestaurantListLoaded extends FoodState {
  final List<RestaurantModel> restaurants;
  final String? selectedCategory;
  final CartModel cart;

  const RestaurantListLoaded({
    required this.restaurants,
    this.selectedCategory,
    this.cart = const CartModel(),
  });

  @override
  List<Object?> get props => [restaurants, selectedCategory, cart];

  RestaurantListLoaded copyWith({
    List<RestaurantModel>? restaurants,
    String? selectedCategory,
    CartModel? cart,
    bool clearCategory = false,
  }) {
    return RestaurantListLoaded(
      restaurants: restaurants ?? this.restaurants,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      cart: cart ?? this.cart,
    );
  }
}

class RestaurantMenuLoaded extends FoodState {
  final RestaurantModel restaurant;
  final List<MenuItemModel> menuItems;
  final Map<String, List<MenuItemModel>> menuByCategory;
  final CartModel cart;

  const RestaurantMenuLoaded({
    required this.restaurant,
    required this.menuItems,
    required this.menuByCategory,
    this.cart = const CartModel(),
  });

  @override
  List<Object?> get props => [restaurant, menuItems, cart];

  RestaurantMenuLoaded copyWith({CartModel? cart}) {
    return RestaurantMenuLoaded(
      restaurant: restaurant,
      menuItems: menuItems,
      menuByCategory: menuByCategory,
      cart: cart ?? this.cart,
    );
  }
}

class OrderPlacing extends FoodState {
  final CartModel cart;

  const OrderPlacing({required this.cart});

  @override
  List<Object?> get props => [cart];
}

class OrderPlaced extends FoodState {
  final OrderModel order;

  const OrderPlaced({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrderTracking extends FoodState {
  final OrderModel order;

  const OrderTracking({required this.order});

  @override
  List<Object?> get props => [order];

  OrderTracking copyWith({OrderModel? order}) {
    return OrderTracking(order: order ?? this.order);
  }
}

class OrderHistoryLoaded extends FoodState {
  final List<OrderModel> orders;

  const OrderHistoryLoaded({required this.orders});

  @override
  List<Object?> get props => [orders];
}

class FoodError extends FoodState {
  final String message;

  const FoodError({required this.message});

  @override
  List<Object?> get props => [message];
}
