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
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'Restaurant',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      deliveryTimeMinutes:
          (json['deliveryTimeMinutes'] as num?)?.toInt() ?? 30,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble() ?? 0,
      isOpen: json['isOpen'] as bool? ?? true,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
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
