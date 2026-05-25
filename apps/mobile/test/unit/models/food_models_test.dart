import 'package:flutter_test/flutter_test.dart';
import 'package:crab_mobile/features/food/data/models/order_model.dart';
import 'package:crab_mobile/features/food/data/models/restaurant_model.dart';
import 'package:crab_mobile/features/food/data/models/menu_item_model.dart';
import 'package:crab_mobile/features/food/data/models/cart_model.dart';

void main() {
  // ═════════════════════════════════════════════════════════════
  // OrderStatus & Extension
  // ═════════════════════════════════════════════════════════════
  group('OrderStatus', () {
    test('label returns human-readable string', () {
      expect(OrderStatus.pending.label, 'Pending');
      expect(OrderStatus.confirmed.label, 'Confirmed');
      expect(OrderStatus.preparing.label, 'Preparing');
      expect(OrderStatus.readyForPickup.label, 'Ready for Pickup');
      expect(OrderStatus.outForDelivery.label, 'Out for Delivery');
      expect(OrderStatus.delivered.label, 'Delivered');
      expect(OrderStatus.cancelled.label, 'Cancelled');
    });

    test('step returns correct progression index', () {
      expect(OrderStatus.pending.step, 0);
      expect(OrderStatus.confirmed.step, 1);
      expect(OrderStatus.preparing.step, 2);
      expect(OrderStatus.readyForPickup.step, 3);
      expect(OrderStatus.outForDelivery.step, 4);
      expect(OrderStatus.delivered.step, 5);
      expect(OrderStatus.cancelled.step, -1);
    });

    test('fromString parses snake_case strings', () {
      expect(OrderStatusLabel.fromString('pending'), OrderStatus.pending);
      expect(OrderStatusLabel.fromString('confirmed'), OrderStatus.confirmed);
      expect(OrderStatusLabel.fromString('preparing'), OrderStatus.preparing);
      expect(OrderStatusLabel.fromString('ready_for_pickup'),
          OrderStatus.readyForPickup);
      expect(OrderStatusLabel.fromString('out_for_delivery'),
          OrderStatus.outForDelivery);
      expect(OrderStatusLabel.fromString('delivered'), OrderStatus.delivered);
      expect(OrderStatusLabel.fromString('cancelled'), OrderStatus.cancelled);
    });

    test('fromString returns pending for unknown values', () {
      expect(OrderStatusLabel.fromString('unknown'), OrderStatus.pending);
      expect(OrderStatusLabel.fromString(''), OrderStatus.pending);
    });
  });

  // ═════════════════════════════════════════════════════════════
  // OrderItemModel
  // ═════════════════════════════════════════════════════════════
  group('OrderItemModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'menuItemId': 'm1',
        'name': 'Pho',
        'price': 55000,
        'quantity': 2,
      };
      final item = OrderItemModel.fromJson(json);
      expect(item.menuItemId, 'm1');
      expect(item.name, 'Pho');
      expect(item.price, 55000);
      expect(item.quantity, 2);
      expect(item.note, isNull);
    });

    test('subtotal computes correctly', () {
      const item = OrderItemModel(
        menuItemId: 'm1',
        name: 'Pho',
        price: 55000,
        quantity: 3,
      );
      expect(item.subtotal, 165000);
    });

    test('fromJson handles note', () {
      final json = {
        'menuItemId': 'm1',
        'name': 'Pho',
        'price': 55000,
        'quantity': 1,
        'note': 'No onions',
      };
      final item = OrderItemModel.fromJson(json);
      expect(item.note, 'No onions');
    });

    test('fromJson defaults empty name', () {
      final json = {
        'menuItemId': 'm1',
        'price': 10000,
        'quantity': 1,
      };
      final item = OrderItemModel.fromJson(json);
      expect(item.name, '');
    });
  });

  // ═════════════════════════════════════════════════════════════
  // OrderModel
  // ═════════════════════════════════════════════════════════════
  group('OrderModel', () {
    final json = {
      'id': 'o1',
      'restaurantId': 'r1',
      'restaurantName': 'Pho 24',
      'items': [
        {'menuItemId': 'm1', 'name': 'Pho', 'price': 55000, 'quantity': 2},
      ],
      'status': 'confirmed',
      'subtotal': 110000,
      'deliveryFee': 15000,
      'total': 125000,
      'currency': 'VND',
      'deliveryAddress': '123 Le Loi',
      'createdAt': '2026-05-20T12:00:00.000',
      'estimatedMinutes': 30,
    };

    test('fromJson parses all fields', () {
      final order = OrderModel.fromJson(json);
      expect(order.id, 'o1');
      expect(order.restaurantId, 'r1');
      expect(order.restaurantName, 'Pho 24');
      expect(order.items.length, 1);
      expect(order.status, OrderStatus.confirmed);
      expect(order.subtotal, 110000);
      expect(order.deliveryFee, 15000);
      expect(order.total, 125000);
      expect(order.currency, 'VND');
      expect(order.deliveryAddress, '123 Le Loi');
      expect(order.estimatedMinutes, 30);
    });

    test('fromJson defaults missing optional fields', () {
      final minimal = {
        'id': 'o2',
        'items': <Map<String, dynamic>>[],
        'status': 'pending',
        'createdAt': '2026-01-01T00:00:00.000',
      };
      final order = OrderModel.fromJson(minimal);
      expect(order.restaurantId, '');
      expect(order.restaurantName, '');
      expect(order.subtotal, 0);
      expect(order.deliveryFee, 0);
      expect(order.total, 0);
      expect(order.currency, 'VND');
      expect(order.deliveryAddress, '');
      expect(order.estimatedMinutes, isNull);
    });

    test('copyWith updates status', () {
      final order = OrderModel.fromJson(json);
      final updated = order.copyWith(status: OrderStatus.delivered);
      expect(updated.status, OrderStatus.delivered);
      expect(updated.id, order.id);
      expect(updated.total, order.total);
    });

    test('copyWith updates estimatedMinutes', () {
      final order = OrderModel.fromJson(json);
      final updated = order.copyWith(estimatedMinutes: 15);
      expect(updated.estimatedMinutes, 15);
    });
  });

  // ═════════════════════════════════════════════════════════════
  // RestaurantModel
  // ═════════════════════════════════════════════════════════════
  group('RestaurantModel', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'r1',
        'name': 'Pho 24',
        'imageUrl': 'https://img.com/pho.jpg',
        'description': 'Best pho',
        'category': 'Vietnamese',
        'rating': 4.5,
        'totalReviews': 320,
        'deliveryTimeMinutes': 25,
        'deliveryFee': 15000,
        'minOrderAmount': 30000,
        'isOpen': true,
        'distanceKm': 1.2,
        'address': '123 Le Loi',
      };
      final r = RestaurantModel.fromJson(json);
      expect(r.id, 'r1');
      expect(r.name, 'Pho 24');
      expect(r.imageUrl, 'https://img.com/pho.jpg');
      expect(r.category, 'Vietnamese');
      expect(r.rating, 4.5);
      expect(r.totalReviews, 320);
      expect(r.deliveryTimeMinutes, 25);
      expect(r.deliveryFee, 15000);
      expect(r.isOpen, true);
      expect(r.distanceKm, 1.2);
    });

    test('fromJson handles null optionals', () {
      final json = {
        'id': 'r2',
        'name': 'Place',
        'category': 'Fast Food',
        'rating': 3.0,
        'totalReviews': 0,
        'deliveryTimeMinutes': 20,
        'deliveryFee': 10000,
        'minOrderAmount': 0,
        'isOpen': false,
      };
      final r = RestaurantModel.fromJson(json);
      expect(r.imageUrl, isNull);
      expect(r.description, isNull);
      expect(r.distanceKm, isNull);
      expect(r.address, isNull);
    });
  });

  // ═════════════════════════════════════════════════════════════
  // MenuItemModel
  // ═════════════════════════════════════════════════════════════
  group('MenuItemModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'm1',
        'restaurantId': 'r1',
        'name': 'Pho Bo',
        'description': 'Beef pho',
        'imageUrl': 'https://img.com/pho.jpg',
        'price': 55000,
        'currency': 'VND',
        'category': 'Main',
        'isAvailable': true,
        'isFeatured': true,
      };
      final item = MenuItemModel.fromJson(json);
      expect(item.id, 'm1');
      expect(item.name, 'Pho Bo');
      expect(item.price, 55000);
      expect(item.isAvailable, true);
      expect(item.isFeatured, true);
    });
  });

  // ═════════════════════════════════════════════════════════════
  // CartModel
  // ═════════════════════════════════════════════════════════════
  group('CartModel', () {
    const menuItem = MenuItemModel(
      id: 'm1',
      restaurantId: 'r1',
      name: 'Pho',
      price: 55000,
      currency: 'VND',
      category: 'Main',
      isAvailable: true,
      isFeatured: false,
    );

    test('empty constructor creates empty cart', () {
      const cart = CartModel();
      expect(cart.items, isEmpty);
      expect(cart.restaurantId, isNull);
      expect(cart.restaurantName, isNull);
      expect(cart.totalItems, 0);
      expect(cart.subtotal, 0);
    });

    test('addItem adds new item', () {
      const cart = CartModel();
      final updated = cart.addItem(menuItem);
      expect(updated.items.length, 1);
      expect(updated.items.first.quantity, 1);
      expect(updated.totalItems, 1);
    });

    test('addItem increments existing item quantity', () {
      final cart = const CartModel().addItem(menuItem);
      final updated = cart.addItem(menuItem);
      expect(updated.items.length, 1);
      expect(updated.items.first.quantity, 2);
      expect(updated.totalItems, 2);
    });

    test('removeItem removes item', () {
      final cart = const CartModel().addItem(menuItem);
      final updated = cart.removeItem(menuItem.id);
      expect(updated.items, isEmpty);
      expect(updated.totalItems, 0);
    });

    test('clear empties everything', () {
      final cart = const CartModel().addItem(menuItem);
      final cleared = cart.clear();
      expect(cleared.items, isEmpty);
    });

    test('subtotal sums all item subtotals', () {
      const item2 = MenuItemModel(
        id: 'm2',
        restaurantId: 'r1',
        name: 'Rolls',
        price: 35000,
        currency: 'VND',
        category: 'App',
        isAvailable: true,
        isFeatured: false,
      );
      final cart = const CartModel().addItem(menuItem).addItem(item2);
      expect(cart.subtotal, 55000 + 35000);
    });
  });

  // ═════════════════════════════════════════════════════════════
  // CartItemModel
  // ═════════════════════════════════════════════════════════════
  group('CartItemModel', () {
    test('subtotal computes correctly', () {
      const item = CartItemModel(
        item: MenuItemModel(
          id: 'm1',
          restaurantId: 'r1',
          name: 'P',
          price: 10000,
          currency: 'VND',
          category: 'C',
          isAvailable: true,
          isFeatured: false,
        ),
        quantity: 5,
      );
      expect(item.subtotal, 50000);
    });
  });
}
