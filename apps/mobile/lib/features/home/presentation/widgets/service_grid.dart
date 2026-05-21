import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import 'service_card.dart';

class ServiceGrid extends StatelessWidget {
  const ServiceGrid({super.key});

  static const _services = <_Service>[
    _Service(
      icon: Icons.motorcycle,
      label: 'Bike',
      route: '/ride/book?type=BIKE',
      tint: AppColors.primary,
    ),
    _Service(
      icon: Icons.directions_car,
      label: 'Car',
      route: '/ride/book?type=CAR_4',
      tint: Color(0xFF2196F3),
    ),
    _Service(
      icon: Icons.restaurant,
      label: 'Food',
      route: '/food',
      tint: Color(0xFFFF6B35),
    ),
    _Service(
      icon: Icons.local_grocery_store,
      label: 'Mart',
      route: '/services',
      tint: Color(0xFF9C27B0),
    ),
    _Service(
      icon: Icons.local_shipping,
      label: 'Express',
      route: '/services',
      tint: Color(0xFFE53935),
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
      tint: Color(0xFF6B7280),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 8,
      childAspectRatio: 0.86,
      children: [
        for (final s in _services)
          ServiceCard(
            label: s.label,
            icon: s.icon,
            tint: s.tint,
            onTap: () => context.push(s.route),
          ),
      ],
    );
  }
}

class _Service {
  const _Service({
    required this.icon,
    required this.label,
    required this.route,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final String route;
  final Color tint;
}
