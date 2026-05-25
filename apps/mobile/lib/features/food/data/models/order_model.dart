enum OrderStatus {
  pending,
  confirmed,
  preparing,
  readyForPickup,
  outForDelivery,
  delivered,
  cancelled,
}

extension OrderStatusLabel on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.readyForPickup:
        return 'Ready for Pickup';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get step {
    switch (this) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.preparing:
        return 2;
      case OrderStatus.readyForPickup:
        return 3;
      case OrderStatus.outForDelivery:
        return 4;
      case OrderStatus.delivered:
        return 5;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  static OrderStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'placed':
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
      case 'ready_for_pickup':
        return OrderStatus.readyForPickup;
      case 'picked_up':
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

class OrderItemModel {
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;
  final String? note;

  const OrderItemModel({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    this.note,
  });

  double get subtotal => price * quantity;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      menuItemId: json['menuItemId'] as String,
      name: json['name'] as String? ?? '',
      price: _asDouble(json['price']),
      quantity: (json['quantity'] as num).toInt(),
      note: json['notes'] as String? ?? json['note'] as String?,
    );
  }
}

class OrderModel {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final List<OrderItemModel> items;
  final OrderStatus status;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String currency;
  final String deliveryAddress;
  final DateTime createdAt;
  final int? estimatedMinutes;

  const OrderModel({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    this.currency = 'VND',
    required this.deliveryAddress,
    required this.createdAt,
    this.estimatedMinutes,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'PLACED';
    final itemsList = (json['items'] as List<dynamic>? ?? [])
        .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return OrderModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      restaurantId: json['restaurantId'] as String? ??
          json['restaurant_id'] as String? ??
          '',
      restaurantName: json['restaurantName'] as String? ?? '',
      items: itemsList,
      status: OrderStatusLabel.fromString(statusStr),
      subtotal: _asDouble(json['subtotal']),
      deliveryFee: _asDouble(json['deliveryFee']),
      total: _asDouble(json['total'] ?? json['totalAmount']),
      currency: json['currency'] as String? ?? 'VND',
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      createdAt: _asDateTime(json['createdAt'] ?? json['created_at']),
      estimatedMinutes: _asInt(
        json['estimatedMinutes'] ?? json['estimated_minutes'],
      ),
    );
  }

  OrderModel copyWith({OrderStatus? status, int? estimatedMinutes}) {
    return OrderModel(
      id: id,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      items: items,
      status: status ?? this.status,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      currency: currency,
      deliveryAddress: deliveryAddress,
      createdAt: createdAt,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    );
  }
}

double _asDouble(Object? value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

int? _asInt(Object? value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

DateTime _asDateTime(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}
