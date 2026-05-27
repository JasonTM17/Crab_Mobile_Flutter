import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_shadows.dart';
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
    if (fee == 0) return 'Freeship';
    final thousand = (fee / 1000).toStringAsFixed(0);
    return '$thousand.000đ';
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
    final feeText = _formatFee(r.deliveryFee);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: r.isOpen ? onTap : null,
          child: Ink(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.borderLight.withValues(alpha: 0.72),
              ),
              boxShadow: AppShadows.shadowSoft,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RestaurantThumb(
                    imageUrl: r.imageUrl,
                    isOpen: r.isOpen,
                    promo: r.deliveryFee == 0,
                    category: r.category,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                r.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondaryLight
                                  .withValues(alpha: 0.78),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _descriptionFor(r),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            _InfoPill(
                              icon: Icons.star_rounded,
                              iconColor: AppColors.secondary,
                              label:
                                  '${r.rating.toStringAsFixed(1)} (${r.totalReviews})',
                            ),
                            _InfoPill(
                              icon: Icons.access_time_filled_rounded,
                              iconColor: AppColors.primary,
                              label: '${r.deliveryTimeMinutes} phút',
                            ),
                            _InfoPill(
                              icon: Icons.delivery_dining_rounded,
                              iconColor: AppColors.accent,
                              label: feeText,
                            ),
                          ],
                        ),
                        if (distanceText.isNotEmpty ||
                            (r.address != null && r.address!.isNotEmpty)) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.place_outlined,
                                size: 16,
                                color: AppColors.textSecondaryLight,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  [
                                    if (distanceText.isNotEmpty) distanceText,
                                    if (r.address != null &&
                                        r.address!.isNotEmpty)
                                      r.address!,
                                  ].join(' · '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _descriptionFor(RestaurantModel restaurant) {
    final description = restaurant.description?.trim();
    if (description != null && description.isNotEmpty) return description;
    return '${restaurant.category} · Món nổi bật, giao nhanh gần bạn';
  }
}

class _RestaurantThumb extends StatelessWidget {
  final String? imageUrl;
  final bool isOpen;
  final bool promo;
  final String category;

  const _RestaurantThumb({
    required this.imageUrl,
    required this.isOpen,
    required this.promo,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          SizedBox(
            width: 96,
            height: 108,
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const _ShimmerBox(),
                    errorWidget: (_, __, ___) =>
                        _ImageFallback(category: category),
                  )
                : _ImageFallback(category: category),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.42),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            top: 8,
            child: _ThumbBadge(
              label: isOpen ? 'Mở cửa' : 'Tạm đóng',
              color: isOpen ? AppColors.primary : AppColors.textSecondaryLight,
            ),
          ),
          if (promo)
            const Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: _ThumbBadge(
                label: 'Freeship',
                color: AppColors.accent,
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _InfoPill({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryLight,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThumbBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _ThumbBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
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
  final String category;

  const _ImageFallback({required this.category});

  @override
  Widget build(BuildContext context) {
    final icon = category.toLowerCase().contains('coffee') ||
            category.toLowerCase().contains('cà phê')
        ? Icons.local_cafe_rounded
        : Icons.restaurant_rounded;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFB020), Color(0xFFFF7A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(icon, size: 42, color: Colors.white),
      ),
    );
  }
}
