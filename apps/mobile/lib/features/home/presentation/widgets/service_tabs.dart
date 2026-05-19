import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Multi-service tab UI inspired by Grab/Uber super-app shell.
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

  static const _tabs = ['Mobility', 'Food & Mart', 'Express', 'Pay'];

  static const _services = <List<_ServiceTile>>[
    [
      _ServiceTile('Bike', Icons.two_wheeler, '/ride/book?type=bike'),
      _ServiceTile('Car 4', Icons.directions_car, '/ride/book?type=car4'),
      _ServiceTile('Car 7', Icons.airport_shuttle, '/ride/book?type=car7'),
      _ServiceTile('Premium', Icons.star, '/ride/book?type=premium'),
      _ServiceTile('Schedule', Icons.schedule, '/ride/book?schedule=1'),
      _ServiceTile('Multi-stop', Icons.alt_route, '/ride/book?stops=1'),
      _ServiceTile('History', Icons.history, '/ride/history'),
      _ServiceTile('Driver', Icons.badge, '/driver/dashboard'),
    ],
    [
      _ServiceTile('Food', Icons.restaurant, '/food'),
      _ServiceTile('Mart', Icons.shopping_basket, '/services'),
      _ServiceTile('Grocery', Icons.local_grocery_store, '/services'),
      _ServiceTile('Cart', Icons.shopping_cart, '/food/cart'),
      _ServiceTile('Orders', Icons.receipt_long, '/food/orders'),
      _ServiceTile('Promos', Icons.local_offer, '/promos'),
    ],
    [
      _ServiceTile('Send', Icons.send, '/services'),
      _ServiceTile('Documents', Icons.description, '/services'),
      _ServiceTile('Track', Icons.local_shipping, '/services'),
    ],
    [
      _ServiceTile('Wallet', Icons.account_balance_wallet, '/wallet'),
      _ServiceTile('Top up', Icons.add_circle, '/wallet/topup'),
      _ServiceTile('Transfer', Icons.swap_horiz, '/wallet/transfer'),
      _ServiceTile('History', Icons.list_alt, '/wallet/transactions'),
      _ServiceTile('Promos', Icons.local_offer, '/promos'),
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
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _controller,
            labelColor: const Color(0xFF00B14F),
            unselectedLabelColor: Colors.black54,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                ),
              ],
            ),
            isScrollable: true,
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
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
                  color: const Color(0xFFE6F7EE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(t.icon, color: const Color(0xFF00B14F)),
              ),
              const SizedBox(height: 6),
              Text(
                t.label,
                style: const TextStyle(fontSize: 12),
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
