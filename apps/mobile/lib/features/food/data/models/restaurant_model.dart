class RestaurantModel {
  final String id;
  final String name;
  final String? imageUrl;
  final String? description;
  final String category;
  final double rating;
  final int totalReviews;
  final int deliveryTimeMinutes;
  final double deliveryFee;
  final double minOrderAmount;
  final bool isOpen;
  final double? distanceKm;
  final String? address;

  const RestaurantModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.description,
    required this.category,
    required this.rating,
    required this.totalReviews,
    required this.deliveryTimeMinutes,
    required this.deliveryFee,
    required this.minOrderAmount,
    required this.isOpen,
    this.distanceKm,
    this.address,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String? ?? json['coverImageUrl'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String? ??
          json['cuisineType'] as String? ??
          'Restaurant',
      rating: _asDouble(json['rating']),
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      deliveryTimeMinutes: (json['deliveryTimeMinutes'] as num?)?.toInt() ??
          (json['avgPrepTimeMin'] as num?)?.toInt() ??
          30,
      deliveryFee: _asDouble(json['deliveryFee']),
      minOrderAmount: _asDouble(
        json['minOrderAmount'] ?? json['minOrderValue'],
      ),
      isOpen: json['isOpen'] as bool? ?? true,
      distanceKm: _asNullableDouble(json['distanceKm'] ?? json['distance_km']),
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'description': description,
        'category': category,
        'rating': rating,
        'totalReviews': totalReviews,
        'deliveryTimeMinutes': deliveryTimeMinutes,
        'deliveryFee': deliveryFee,
        'minOrderAmount': minOrderAmount,
        'isOpen': isOpen,
        'distanceKm': distanceKm,
        'address': address,
      };
}

double _asDouble(Object? value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

double? _asNullableDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
