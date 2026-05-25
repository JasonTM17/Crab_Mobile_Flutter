import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_theme.dart';

class SavedPlaces extends StatelessWidget {
  const SavedPlaces({super.key});

  @override
  Widget build(BuildContext context) {
    const places = [
      _Place(
          icon: Icons.home_outlined,
          label: 'Nhà',
          route: '/ride/book?from=home'),
      _Place(
          icon: Icons.work_outline,
          label: 'Công ty',
          route: '/ride/book?from=work'),
      _Place(
          icon: Icons.favorite_outline,
          label: 'Đã lưu',
          route: '/ride/book?from=saved'),
    ];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: places.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          if (index == places.length) return const _AddChip();
          return _PlaceChip(place: places[index]);
        },
      ),
    );
  }
}

class _Place {
  const _Place({required this.icon, required this.label, required this.route});

  final IconData icon;
  final String label;
  final String route;
}

class _PlaceChip extends StatelessWidget {
  const _PlaceChip({required this.place});

  final _Place place;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: 'Đi tới ${place.label}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(place.route),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border:
                  Border.all(color: cs.outlineVariant.withValues(alpha: 0.84)),
              boxShadow: isDark ? null : AppShadows.shadowSoft,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(place.icon, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  place.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
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

class _AddChip extends StatelessWidget {
  const _AddChip();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Thêm địa điểm đã lưu',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/profile'),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: AppColors.primary.withValues(alpha: 0.45),
              radius: AppRadii.pill,
            ),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add,
                        size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Text(
                    'Thêm',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
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
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dash;
        canvas.drawPath(
            metric.extractPath(distance, next.clamp(0, metric.length)), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
