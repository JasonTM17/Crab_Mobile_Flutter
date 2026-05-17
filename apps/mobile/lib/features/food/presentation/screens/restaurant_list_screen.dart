import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/restaurant_model.dart';
import '../bloc/food_bloc.dart';
import '../bloc/food_event.dart';
import '../bloc/food_state.dart';
import 'restaurant_menu_screen.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  static const _categories = [
    'All',
    'Vietnamese',
    'Fast Food',
    'Pizza',
    'Sushi',
    'Dessert',
    'Drinks',
  ];

  @override
  void initState() {
    super.initState();
    context.read<FoodBloc>().add(const LoadRestaurants());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Food'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<FoodBloc, FoodState>(
        builder: (context, state) {
          if (state is FoodLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FoodError) {
            return _ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<FoodBloc>().add(const LoadRestaurants()),
            );
          }

          if (state is RestaurantListLoaded) {
            return _RestaurantListBody(
              state: state,
              categories: _categories,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _RestaurantListBody extends StatelessWidget {
  final RestaurantListLoaded state;
  final List<String> categories;

  const _RestaurantListBody({
    required this.state,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCategory = state.selectedCategory;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == 'All'
                    ? selectedCategory == null
                    : selectedCategory == cat;
                return FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) {
                    context.read<FoodBloc>().add(FilterCategoryChanged(
                          category: cat == 'All' ? null : cat,
                        ));
                  },
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Free delivery today!',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'On your first order',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              '${state.restaurants.length} restaurants nearby',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (state.restaurants.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Text('No restaurants found'),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _RestaurantCard(
                  restaurant: state.restaurants[index],
                  onTap: () {
                    context.read<FoodBloc>().add(
                          LoadRestaurantMenu(
                            restaurant: state.restaurants[index],
                          ),
                        );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<FoodBloc>(),
                          child: const RestaurantMenuScreen(),
                        ),
                      ),
                    );
                  },
                ),
                childCount: state.restaurants.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final VoidCallback onTap;

  const _RestaurantCard({required this.restaurant, required this.onTap});

  String _formatFee(double fee) {
    if (fee == 0) return 'Free delivery';
    if (fee >= 1000) return '${(fee / 1000).toStringAsFixed(0)}k delivery';
    return '${fee.toStringAsFixed(0)} delivery';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: restaurant.isOpen ? onTap : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 160,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: restaurant.imageUrl != null
                      ? Image.network(
                          restaurant.imageUrl!,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const _PlaceholderImage(),
                        )
                      : const _PlaceholderImage(),
                ),
                if (!restaurant.isOpen)
                  Container(
                    height: 160,
                    color: Colors.black54,
                    child: const Center(
                      child: Text(
                        'Closed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              restaurant.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.category,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.deliveryTimeMinutes} min',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.delivery_dining,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        _formatFee(restaurant.deliveryFee),
                        style: TextStyle(
                          fontSize: 13,
                          color: restaurant.deliveryFee == 0
                              ? Colors.green
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (restaurant.distanceKm != null) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.location_on,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${restaurant.distanceKm!.toStringAsFixed(1)} km',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.restaurant,
        size: 48,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
