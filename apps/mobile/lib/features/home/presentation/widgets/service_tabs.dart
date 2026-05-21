import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

/// Multi-service tab UI inspired by Grab/Be super-app shell.
/// Tabs: Mobility / Food & Mart / Express / Pay
/// Each tab shows a 2x4 grid of service tiles with icons + labels.
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
      _ServiceTile('Bike', Icons.two_wheeler, '/ride/book?type=bike'),
      _ServiceTile('Car 4', Icons.directions_car, '/ride/book?type=car4'),
      _ServiceTile('Car 7', Icons.airport_shuttle, '/ride/book?type=car7'),
      _ServiceTile('Premium', Icons.star, '/ride/book?type=premium'),
      _ServiceTile('Đặt lịch', Icons.schedule, '/ride/book?schedule=1'),
      _ServiceTile('Nhiều điểm', Icons.alt_route, '/ride/book?stops=1'),
      _ServiceTile('Lịch sử', Icons.history, '/ride/history'),
      _ServiceTile('Tài xế', Icons.badge, '/driver/dashboard'),
    ],
    [
      _ServiceTile('Food', Icons.restaurant, '/food'),
      _ServiceTile('Mart', Icons.shopping_basket, '/services'),
      _ServiceTile('Tạp hoá', Icons.local_grocery_store, '/services'),
      _ServiceTile('Giỏ hàng', Icons.shopping_cart, '/food/cart'),
      _ServiceTile('Đơn hàng', Icons.receipt_long, '/food/orders'),
      _ServiceTile('Khuyến mãi', Icons.local_offer, '/promos'),
    ],
    [
      _ServiceTile('Gửi đồ', Icons.send, '/services'),
      _ServiceTile('Tài liệu', Icons.description, '/services'),
      _ServiceTile('Theo dõi', Icons.local_shipping, '/services'),
    ],
    [
      _ServiceTile('Ví', Icons.account_balance_wallet, '/wallet'),
      _ServiceTile('Nạp tiền', Icons.add_circle, '/wallet/topup'),
      _ServiceTile('Chuyển', Icons.swap_horiz, '/wallet/transfer'),
      _ServiceTile('Lịch sử', Icons.list_alt, '/wallet/transactions'),
      _ServiceTile('Khuyến mãi', Icons.local_offer, '/promos'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 40,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: _tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final selected = _controller.index == i;
                  return _TabPill(
                    label: _tabs[i],
                    selected: selected,
                    onTap: () => _controller.animateTo(i),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 230,
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
  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = selected
        ? AppColors.primary
        : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);
    final fg = selected
        ? Colors.white
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);
    final border = selected
        ? AppColors.primary
        : (isDark ? AppColors.borderDark : AppColors.borderLight);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border, width: 1),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceTile {
  final String label;
  final IconData icon;
  final String route;
  const _ServiceTile(this.label, this.icon, this.route);
}

class _ServiceGridView extends StatelessWidget {
  final List<_ServiceTile> tiles;
  const _ServiceGridView({required this.tiles});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 8,
        childAspectRatio: 0.95,
      ),
      itemCount: tiles.length,
      itemBuilder: (context, i) {
        final t = tiles[i];
        return InkWell(
          onTap: () => context.push(t.route),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(t.icon, color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              Text(
                t.label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

