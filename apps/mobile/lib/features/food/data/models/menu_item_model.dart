class MenuItemModel {
  final String id;
  final String restaurantId;
  final String name;
  final String? description;
  final String? imageUrl;
  final double price;
  final String currency;
  final String category;
  final bool isAvailable;
  final bool isFeatured;

  const MenuItemModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.price,
    this.currency = 'VND',
    required this.category,
    required this.isAvailable,
    this.isFeatured = false,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String? ?? '',
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      price: _asDouble(json['discountPrice'] ?? json['price']),
      currency: json['currency'] as String? ?? 'VND',
      category: json['category'] as String? ??
          json['categoryId'] as String? ??
          'Main',
      isAvailable: json['isAvailable'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'restaurantId': restaurantId,
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'price': price,
        'currency': currency,
        'category': category,
        'isAvailable': isAvailable,
        'isFeatured': isFeatured,
      };
}

double _asDouble(Object? value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}
