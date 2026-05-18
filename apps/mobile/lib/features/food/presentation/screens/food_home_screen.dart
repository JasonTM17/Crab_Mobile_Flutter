import 'package:flutter/material.dart';

class FoodHomeScreen extends StatelessWidget {
  const FoodHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search restaurants or dishes',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Categories', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _CategoryChip(icon: Icons.lunch_dining, label: 'Burger'),
                _CategoryChip(icon: Icons.local_pizza, label: 'Pizza'),
                _CategoryChip(icon: Icons.ramen_dining, label: 'Noodle'),
                _CategoryChip(icon: Icons.rice_bowl, label: 'Rice'),
                _CategoryChip(icon: Icons.local_drink, label: 'Drinks'),
                _CategoryChip(icon: Icons.cake, label: 'Dessert'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Popular nearby',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...List.generate(5, (i) => _RestaurantCard(index: i)),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CategoryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFFF6B6B).withOpacity(0.1),
            child: Icon(icon, color: const Color(0xFFFF6B6B)),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final int index;
  const _RestaurantCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 56,
            height: 56,
            color: Colors.orange[100],
            child: const Icon(Icons.restaurant, color: Colors.orange),
          ),
        ),
        title: Text('Restaurant ${index + 1}'),
        subtitle: const Text('★ 4.5 · 25 min · 15k delivery'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
