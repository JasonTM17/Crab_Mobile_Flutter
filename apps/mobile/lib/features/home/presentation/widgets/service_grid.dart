import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import 'service_card.dart';

class ServiceGrid extends StatelessWidget {
  const ServiceGrid({super.key});

  static const _services = <_Service>[
    _Service(
      icon: Icons.motorcycle,
      label: 'Xe máy',
      route: '/ride/book?type=BIKE',
      tint: AppColors.primary,
    ),
    _Service(
      icon: Icons.directions_car,
      label: 'Ô tô',
      route: '/ride/book?type=CAR_4',
      tint: AppColors.info,
    ),
    _Service(
      icon: Icons.restaurant,
      label: 'Đồ ăn',
      route: '/food',
      tint: Color(0xFFFF7A1A),
    ),
    _Service(
      icon: Icons.account_balance_wallet,
      label: 'Ví Crab',
      route: '/wallet',
      tint: AppColors.accent,
    ),
    _Service(
      icon: Icons.local_offer,
      label: 'Ưu đãi',
      route: '/promos',
      tint: Color(0xFFE85D04),
    ),
    _Service(
      icon: Icons.more_horiz,
      label: 'Thêm',
      route: '/services',
      tint: Color(0xFF667085),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.08,
      children: [
        for (final service in _services)
          ServiceCard(
            label: service.label,
            icon: service.icon,
            tint: service.tint,
            onTap: () => context.push(service.route),
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
