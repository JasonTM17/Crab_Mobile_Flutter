import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

class SavedPlaces extends StatelessWidget {
  const SavedPlaces({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final places = const [
      _Place(icon: Icons.home_outlined, label: 'Home', route: '/ride/book?from=home'),
      _Place(icon: Icons.work_outline, label: 'Work', route: '/ride/book?from=work'),
      _Place(icon: Icons.favorite_outline, label: 'Saved', route: '/ride/book?from=saved'),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: places.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          if (i == places.length) {
            return _AddChip(isDark: isDark);
          }
          return _PlaceChip(place: places[i], isDark: isDark);
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
  const _PlaceChip({required this.place, required this.isDark});
  final _Place place;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final fill = isDark ? AppColors.surfaceDark : Colors.white;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final fg = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(place.route),
        borderRadius: BorderRadius.circular(99),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(place.icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                place.label,
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddChip extends StatelessWidget {
  const _AddChip({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final tint = AppColors.primary.withValues(alpha: 0.10);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/profile'),
        borderRadius: BorderRadius.circular(99),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.30),
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.add, size: 16, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                'Add place',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
