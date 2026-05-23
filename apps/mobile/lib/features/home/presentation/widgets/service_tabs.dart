import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_theme.dart';

class ServiceTabs extends StatefulWidget {
  const ServiceTabs({super.key});

  @override
  State<ServiceTabs> createState() => _ServiceTabsState();
}

class _ServiceTabsState extends State<ServiceTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  static const _tabs = ['Di chuyển', 'Ăn uống', 'Giao hàng', 'Thanh toán'];
  static const _services = <List<_ServiceTile>>[
    [
      _ServiceTile(
          'Bike', Icons.two_wheeler, '/ride/book?type=bike', AppColors.primary),
      _ServiceTile('Car 4', Icons.directions_car, '/ride/book?type=car4',
          AppColors.info),
      _ServiceTile('Car 7', Icons.airport_shuttle, '/ride/book?type=car7',
          AppColors.warning),
      _ServiceTile(
          'Premium', Icons.star, '/ride/book?type=premium', Color(0xFF7C3AED)),
      _ServiceTile('Đặt lịch', Icons.schedule, '/ride/book?schedule=1',
          AppColors.accent),
      _ServiceTile('Nhiều điểm', Icons.alt_route, '/ride/book?stops=1',
          AppColors.primaryDark),
      _ServiceTile(
          'Lịch sử', Icons.history, '/ride/history', Color(0xFF475467)),
      _ServiceTile(
          'Tài xế', Icons.badge, '/driver/dashboard', Color(0xFF0EA5E9)),
    ],
    [
      _ServiceTile('Food', Icons.restaurant, '/food', Color(0xFFFF6B35)),
      _ServiceTile(
          'Mart', Icons.shopping_basket, '/services', Color(0xFFA855F7)),
      _ServiceTile(
          'Tạp hoá', Icons.local_grocery_store, '/services', AppColors.primary),
      _ServiceTile(
          'Giỏ hàng', Icons.shopping_cart, '/food/cart', AppColors.secondary),
      _ServiceTile(
          'Đơn hàng', Icons.receipt_long, '/food/orders', AppColors.info),
      _ServiceTile(
          'Khuyến mãi', Icons.local_offer, '/promos', Color(0xFFE11D48)),
    ],
    [
      _ServiceTile('Gửi đồ', Icons.send, '/services', AppColors.primary),
      _ServiceTile('Tài liệu', Icons.description, '/services', AppColors.info),
      _ServiceTile(
          'Theo dõi', Icons.local_shipping, '/services', AppColors.warning),
    ],
    [
      _ServiceTile(
          'Ví', Icons.account_balance_wallet, '/wallet', AppColors.primary),
      _ServiceTile(
          'Nạp tiền', Icons.add_circle, '/wallet/topup', AppColors.secondary),
      _ServiceTile(
          'Chuyển', Icons.swap_horiz, '/wallet/transfer', AppColors.accent),
      _ServiceTile(
          'Lịch sử', Icons.list_alt, '/wallet/transactions', Color(0xFF475467)),
      _ServiceTile(
          'Khuyến mãi', Icons.local_offer, '/promos', Color(0xFFE11D48)),
    ],
  ];

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tabShell = cs.surfaceContainerHighest
        .withValues(alpha: theme.brightness == Brightness.dark ? 0.4 : 0.62);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: tabShell,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: SizedBox(
            height: 40,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: _tabs.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    return _TabPill(
                      label: _tabs[index],
                      selected: _controller.index == index,
                      onTap: () => _controller.animateTo(index),
                    );
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 244,
          child: TabBarView(
            controller: _controller,
            children: _services
                .map((tiles) => _ServiceGridView(tiles: tiles))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? cs.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: selected
                  ? cs.primary.withValues(alpha: 0.18)
                  : Colors.transparent,
            ),
            boxShadow: selected && !isDark ? AppShadows.shadowSoft : null,
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: selected ? cs.primary : cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceTile {
  const _ServiceTile(this.label, this.icon, this.route, this.tint);

  final String label;
  final IconData icon;
  final String route;
  final Color tint;
}

class _ServiceGridView extends StatelessWidget {
  const _ServiceGridView({required this.tiles});

  final List<_ServiceTile> tiles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.82,
      ),
      itemCount: tiles.length,
      itemBuilder: (context, index) {
        final tile = tiles[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push(tile.route),
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Ink(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.82)),
                boxShadow: isDark ? null : AppShadows.shadowSoft,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: tile.tint.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(tile.icon, color: tile.tint, size: 22),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    tile.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
