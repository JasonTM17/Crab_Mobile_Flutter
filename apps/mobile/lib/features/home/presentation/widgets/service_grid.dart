import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ServiceGrid extends StatelessWidget {
  const ServiceGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      _Service(icon: Icons.motorcycle, label: 'Bike', color: const Color(0xFF00B14F), route: '/ride/book?type=BIKE'),
      _Service(icon: Icons.directions_car, label: 'Car', color: const Color(0xFF2196F3), route: '/ride/book?type=CAR_4'),
      _Service(icon: Icons.restaurant, label: 'Food', color: const Color(0xFFFF6B6B), route: '/food'),
      _Service(icon: Icons.local_grocery_store, label: 'Mart', color: const Color(0xFFFFA726), route: '/mart'),
      _Service(icon: Icons.local_shipping, label: 'Express', color: const Color(0xFF9C27B0), route: '/express'),
      _Service(icon: Icons.payment, label: 'Pay', color: const Color(0xFF00BCD4), route: '/wallet'),
      _Service(icon: Icons.local_offer, label: 'Promos', color: const Color(0xFFE91E63), route: '/promos'),
      _Service(icon: Icons.more_horiz, label: 'More', color: const Color(0xFF607D8B), route: '/services'),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: services.map((s) => _ServiceTile(service: s)).toList(),
    );
  }
}

class _Service {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  _Service({required this.icon, required this.label, required this.color, required this.route});
}

class _ServiceTile extends StatelessWidget {
  final _Service service;
  const _ServiceTile({required this.service});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(service.route),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: service.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(service.icon, color: service.color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(service.label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
