import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/cart_model.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/food_repository.dart';
import '../../../../core/network/socket_client.dart';
import 'food_event.dart';
import 'food_state.dart';

@injectable
class FoodBloc extends Bloc<FoodEvent, FoodState> {
  final FoodRepository _foodRepository;
  final SocketClient _socketClient;

  FoodBloc(this._foodRepository, this._socketClient)
      : super(const FoodInitial()) {
    on<LoadRestaurants>(_onLoadRestaurants);
    on<LoadRestaurantMenu>(_onLoadRestaurantMenu);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);
    on<PlaceOrder>(_onPlaceOrder);
    on<LoadOrderHistory>(_onLoadOrderHistory);
    on<LoadActiveOrder>(_onLoadActiveOrder);
    on<OrderStatusUpdated>(_onOrderStatusUpdated);
    on<CancelOrder>(_onCancelOrder);
    on<FilterCategoryChanged>(_onFilterCategoryChanged);
  }

  Future<void> _onLoadRestaurants(
    LoadRestaurants event,
    Emitter<FoodState> emit,
  ) async {
    emit(const FoodLoading());
    try {
      final restaurants = await _foodRepository.getRestaurants(
        category: event.category,
      );
      emit(RestaurantListLoaded(
        restaurants: restaurants,
        selectedCategory: event.category,
      ));
    } catch (e) {
      emit(FoodError(message: _parseError(e)));
    }
  }

  Future<void> _onLoadRestaurantMenu(
    LoadRestaurantMenu event,
    Emitter<FoodState> emit,
  ) async {
    final currentCart = _currentCart;
    emit(const FoodLoading());
    try {
      final items = await _foodRepository.getMenu(event.restaurant.id);
      final byCategory = <String, List<MenuItemModel>>{};
      for (final item in items) {
        byCategory.putIfAbsent(item.category, () => []).add(item);
      }
      emit(RestaurantMenuLoaded(
        restaurant: event.restaurant,
        menuItems: items,
        menuByCategory: byCategory,
        cart: currentCart,
      ));
    } catch (e) {
      emit(FoodError(message: _parseError(e)));
    }
  }

  void _onAddToCart(AddToCart event, Emitter<FoodState> emit) {
    final cart = _currentCart;
    final state = this.state;

    if (state is RestaurantMenuLoaded) {
      final updated = cart.addItem(
        event.item,
        restaurantId: state.restaurant.id,
        restaurantName: state.restaurant.name,
      );
      emit(state.copyWith(cart: updated));
    } else if (state is RestaurantListLoaded) {
      final updated = cart.addItem(event.item);
      emit(state.copyWith(cart: updated));
    }
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<FoodState> emit) {
    final cart = _currentCart.removeItem(event.itemId);
    final state = this.state;
    if (state is RestaurantMenuLoaded) {
      emit(state.copyWith(cart: cart));
    } else if (state is RestaurantListLoaded) {
      emit(state.copyWith(cart: cart));
    }
  }

  void _onClearCart(ClearCart event, Emitter<FoodState> emit) {
    final state = this.state;
    if (state is RestaurantMenuLoaded) {
      emit(state.copyWith(cart: const CartModel()));
    } else if (state is RestaurantListLoaded) {
      emit(state.copyWith(cart: const CartModel()));
    }
  }

  Future<void> _onPlaceOrder(
    PlaceOrder event,
    Emitter<FoodState> emit,
  ) async {
    final cart = _currentCart;
    if (cart.isEmpty || cart.restaurantId == null) return;

    emit(OrderPlacing(cart: cart));
    try {
      final order = await _foodRepository.placeOrder(
        restaurantId: cart.restaurantId!,
        items: cart.toOrderItems(),
        deliveryAddress: event.deliveryAddress,
      );
      emit(OrderPlaced(order: order));
      await _subscribeToOrderSocket(order.id);
      emit(OrderTracking(order: order));
    } catch (e) {
      emit(FoodError(message: _parseError(e)));
    }
  }

  Future<void> _onLoadOrderHistory(
    LoadOrderHistory event,
    Emitter<FoodState> emit,
  ) async {
    emit(const FoodLoading());
    try {
      final orders = await _foodRepository.getOrderHistory();
      emit(OrderHistoryLoaded(orders: orders));
    } catch (e) {
      emit(FoodError(message: _parseError(e)));
    }
  }

  Future<void> _onLoadActiveOrder(
    LoadActiveOrder event,
    Emitter<FoodState> emit,
  ) async {
    try {
      final order = await _foodRepository.getActiveOrder();
      if (order != null) {
        emit(OrderTracking(order: order));
        await _subscribeToOrderSocket(order.id);
      }
    } catch (_) {}
  }

  void _onOrderStatusUpdated(
    OrderStatusUpdated event,
    Emitter<FoodState> emit,
  ) {
    if (state is OrderTracking) {
      final current = (state as OrderTracking).order;
      if (current.id == event.orderId) {
        final updated = current.copyWith(
          status: OrderStatusLabel.fromString(event.status),
          estimatedMinutes: event.estimatedMinutes,
        );
        emit(OrderTracking(order: updated));
      }
    }
  }

  Future<void> _onCancelOrder(
    CancelOrder event,
    Emitter<FoodState> emit,
  ) async {
    try {
      await _foodRepository.cancelOrder(event.orderId);
      if (state is OrderTracking) {
        final current = (state as OrderTracking).order;
        emit(OrderTracking(
          order: current.copyWith(status: OrderStatus.cancelled),
        ));
      }
    } catch (e) {
      emit(FoodError(message: _parseError(e)));
    }
  }

  void _onFilterCategoryChanged(
    FilterCategoryChanged event,
    Emitter<FoodState> emit,
  ) {
    if (state is RestaurantListLoaded) {
      final current = state as RestaurantListLoaded;
      emit(current.copyWith(
        selectedCategory: event.category,
        clearCategory: event.category == null,
      ));
    }
  }

  CartModel get _currentCart {
    return switch (state) {
      RestaurantListLoaded s => s.cart,
      RestaurantMenuLoaded s => s.cart,
      _ => const CartModel(),
    };
  }

  Future<void> _subscribeToOrderSocket(String orderId) async {
    final socket = await _socketClient.foodSocket;
    socket.emit('subscribe_order', {'orderId': orderId});
    socket.on('order_status', (data) {
      final d = data as Map<String, dynamic>;
      if (d['orderId'] == orderId) {
        add(OrderStatusUpdated(
          orderId: orderId,
          status: d['status'] as String,
          estimatedMinutes: (d['estimatedMinutes'] as num?)?.toInt(),
        ));
      }
    });
  }

  String _parseError(Object e) =>
      e.toString().replaceAll('Exception: ', '');
}
