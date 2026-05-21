import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/restaurant_model.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  String _formatFee(double fee) {
    if (fee == 0) return 'Miễn phí giao';
    final thousand = (fee / 1000).toStringAsFixed(0);
    return '$thousand.000đ phí giao';
  }

  String _formatDistance(double? km) {
    if (km == null) return '';
    return '${km.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final r = restaurant;
    final theme = Theme.of(context);
    final distanceText = _formatDistance(r.distanceKm);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: r.isOpen ? onTap : null,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroImage(
                  imageUrl: r.imageUrl,
                  distanceText: distanceText,
                  isOpen: r.isOpen,
                  promo: r.deliveryFee == 0,
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      _MetaRow(
                        rating: r.rating,
                        deliveryMinutes: r.deliveryTimeMinutes,
                        feeText: _formatFee(r.deliveryFee),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  final String? imageUrl;
  final String distanceText;
  final bool isOpen;
  final bool promo;

  const _HeroImage({
    required this.imageUrl,
    required this.distanceText,
    required this.isOpen,
    required this.promo,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Stack(
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const _ShimmerBox(),
                    errorWidget: (_, __, ___) => const _ImageFallback(),
                  )
                : const _ImageFallback(),
          ),
          if (promo)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'FREESHIP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          if (distanceText.isNotEmpty)
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      distanceText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!isOpen)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.45),
                alignment: Alignment.center,
                child: const Text(
                  'Đang đóng cửa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final double rating;
  final int deliveryMinutes;
  final String feeText;

  const _MetaRow({
    required this.rating,
    required this.deliveryMinutes,
    required this.feeText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 14),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(width: 8),
        const _Dot(),
        const SizedBox(width: 8),
        Text(
          '$deliveryMinutes phút',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(width: 8),
        const _Dot(),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            feeText,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      decoration: const BoxDecoration(
        color: AppColors.textSecondaryLight,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.borderLight.withValues(alpha: 0.4),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFB347), Color(0xFFFFCC70)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.restaurant_rounded, size: 56, color: Colors.white),
      ),
    );
  }
}
