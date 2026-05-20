import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_theme.dart';

class ServiceGrid extends StatelessWidget {
  const ServiceGrid({super.key});

  static const _services = <_Service>[
    _Service(
      icon: Icons.motorcycle,
      label: 'Bike',
      route: '/ride/book?type=BIKE',
      gradient: AppGradients.primary,
      featured: true,
    ),
    _Service(
      icon: Icons.directions_car,
      label: 'Car',
      route: '/ride/book?type=CAR_4',
      gradient: AppGradients.ocean,
      featured: true,
    ),
    _Service(
      icon: Icons.restaurant,
      label: 'Food',
      route: '/food',
      gradient: AppGradients.sunset,
      featured: true,
    ),
    _Service(
      icon: Icons.local_shipping,
      label: 'Express',
      route: '/services',
      gradient: AppGradients.violet,
      featured: true,
    ),
    _Service(
      icon: Icons.local_grocery_store,
      label: 'Mart',
      route: '/services',
      tint: Color(0xFFFFA726),
    ),
    _Service(
      icon: Icons.payment,
      label: 'Pay',
      route: '/wallet',
      tint: Color(0xFF00BCD4),
    ),
    _Service(
      icon: Icons.local_offer,
      label: 'Promos',
      route: '/promos',
      tint: Color(0xFFE91E63),
    ),
    _Service(
      icon: Icons.more_horiz,
      label: 'More',
      route: '/services',
      tint: Color(0xFF607D8B),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 16,
      crossAxisSpacing: 8,
      childAspectRatio: 0.86,
      children: [
        for (final s in _services) _ServiceTile(service: s),
      ],
    );
  }
}

class _Service {
  const _Service({
    required this.icon,
    required this.label,
    required this.route,
    this.gradient,
    this.tint,
    this.featured = false,
  });

  final IconData icon;
  final String label;
  final String route;
  final LinearGradient? gradient;
  final Color? tint;
  final bool featured;
}

class _ServiceTile extends StatefulWidget {
  const _ServiceTile({required this.service});

  final _Service service;

  @override
  State<_ServiceTile> createState() => _ServiceTileState();
}

class _ServiceTileState extends State<_ServiceTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.fast,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _down(_) => _controller.forward();
  void _up(_) => _controller.reverse();
  void _cancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final featured = s.featured;
    final iconSize = featured ? 26.0 : 22.0;
    final boxSize = featured ? 56.0 : 48.0;

    final tint = s.tint ?? AppColors.primary;
    final softFill = isDark
        ? tint.withValues(alpha: 0.18)
        : tint.withValues(alpha: 0.12);

    final box = Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        gradient: featured ? s.gradient : null,
        color: featured ? null : softFill,
        borderRadius: BorderRadius.circular(featured ? 18 : 14),
        boxShadow: featured
            ? AppShadows.coloredGlow(
                s.gradient?.colors.first ?? tint,
                opacity: 0.22,
              )
            : null,
      ),
      child: Icon(
        s.icon,
        color: featured ? Colors.white : tint,
        size: iconSize,
      ),
    );

    return GestureDetector(
      onTapDown: _down,
      onTapUp: _up,
      onTapCancel: _cancel,
      onTap: () => context.push(s.route),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = Curves.easeOut.transform(_controller.value);
          final scale = 1 - 0.06 * t;
          return Transform.scale(scale: scale, child: child);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            box,
            const SizedBox(height: 8),
            Text(
              s.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: featured ? FontWeight.w600 : FontWeight.w500,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
