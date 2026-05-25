import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const _items = [
    _ServiceItem('Bike', 'Fast motorbike rides', Icons.motorcycle,
        '/ride/book?type=BIKE'),
    _ServiceItem('Car', 'Comfortable city trips', Icons.directions_car,
        '/ride/book?type=CAR_4'),
    _ServiceItem('Food', 'Restaurants nearby', Icons.restaurant, '/food'),
    _ServiceItem('Mart', 'Daily essentials and grocery delivery',
        Icons.local_grocery_store, '/food'),
    _ServiceItem('Express', 'Fast city delivery for small parcels',
        Icons.local_shipping, '/ride/book?type=BIKE'),
    _ServiceItem('Wallet', 'Balance and payments', Icons.account_balance_wallet,
        '/wallet'),
    _ServiceItem('Promos', 'Active vouchers and Crab rewards', Icons.local_offer,
        '/promos'),
    _ServiceItem('Chat', 'Messages with drivers and merchants',
        Icons.chat_bubble, '/chat'),
    _ServiceItem('Notifications', 'Updates and receipts', Icons.notifications,
        '/notifications'),
    _ServiceItem('Activity', 'Rides, orders, and wallet timeline', Icons.history,
        '/activity'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _items[index];
          return ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: Theme.of(context).colorScheme.surface,
            leading:
                Icon(item.icon, color: Theme.of(context).colorScheme.primary),
            title: Text(item.title),
            subtitle: Text(item.subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(item.route),
          );
        },
      ),
    );
  }
}

class _ServiceItem {
  const _ServiceItem(this.title, this.subtitle, this.icon, this.route);
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
}
