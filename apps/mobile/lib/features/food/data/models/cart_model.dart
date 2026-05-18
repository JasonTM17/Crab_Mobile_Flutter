import 'menu_item_model.dart';

class CartItemModel {
  final MenuItemModel item;
  final int quantity;
  final String? note;

  const CartItemModel({
    required this.item,
    required this.quantity,
    this.note,
  });

  double get subtotal => item.price * quantity;

  CartItemModel copyWith({int? quantity, String? note}) {
    return CartItemModel(
      item: item,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }
}

class CartModel {
  final String? restaurantId;
  final String? restaurantName;
  final List<CartItemModel> items;

  const CartModel({
    this.restaurantId,
    this.restaurantName,
    this.items = const [],
  });

  bool get isEmpty => items.isEmpty;
  int get totalItems => items.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => items.fold(0, (sum, i) => sum + i.subtotal);

  CartModel addItem(MenuItemModel item, {String? restaurantId, String? restaurantName}) {
    // Clear cart if switching restaurants
    if (this.restaurantId != null && this.restaurantId != (restaurantId ?? this.restaurantId)) {
      return CartModel(
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        items: [CartItemModel(item: item, quantity: 1)],
      );
    }

    final existing = items.indexWhere((ci) => ci.item.id == item.id);
    final updated = List<CartItemModel>.from(items);
    if (existing >= 0) {
      updated[existing] = updated[existing].copyWith(
        quantity: updated[existing].quantity + 1,
      );
    } else {
      updated.add(CartItemModel(item: item, quantity: 1));
    }
    return CartModel(
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      items: updated,
    );
  }

  CartModel removeItem(String itemId) {
    final updated = items
        .map((ci) => ci.item.id == itemId
            ? ci.copyWith(quantity: ci.quantity - 1)
            : ci)
        .where((ci) => ci.quantity > 0)
        .toList();
    return CartModel(
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      items: updated,
    );
  }

  CartModel clear() => const CartModel();

  List<Map<String, dynamic>> toOrderItems() {
    return items
        .map((ci) => {
              'menuItemId': ci.item.id,
              'quantity': ci.quantity,
              'note': ci.note,
            })
        .toList();
  }
}
