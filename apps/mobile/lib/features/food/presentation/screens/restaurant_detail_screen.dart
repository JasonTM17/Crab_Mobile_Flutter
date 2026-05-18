import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/food_bloc.dart';
import '../bloc/food_event.dart';
import '../bloc/food_state.dart';
import 'cart_screen.dart';

class RestaurantDetailScreen extends StatelessWidget {
  const RestaurantDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FoodBloc, FoodState>(
      builder: (context, state) {
        if (state is FoodLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is! RestaurantMenuLoaded) {
          return const Scaffold(body: Center(child: Text('Error')));
        }

        final restaurant = state.restaurant;
        final categories = state.menuByCategory.keys.toList();

        return DefaultTabController(
          length: categories.length,
          child: Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(restaurant.name),
                    background: restaurant.imageUrl != null
                        ? Image.network(
                            restaurant.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.orange.shade100,
                              child: const Icon(Icons.restaurant, size: 64),
                            ),
                          )
                        : Container(
                            color: Colors.orange.shade100,
                            child: const Icon(Icons.restaurant, size: 64),
                          ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text('${restaurant.rating}'),
                            const SizedBox(width: 16),
                            Text(restaurant.category),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: restaurant.isOpen
                                    ? Colors.green.shade50
                                    : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                restaurant.isOpen ? 'Open' : 'Closed',
                                style: TextStyle(
                                  color: restaurant.isOpen
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (restaurant.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            restaurant.description!,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      isScrollable: true,
                      tabs: categories.map((c) => Tab(text: c)).toList(),
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                children: categories.map((category) {
                  final items = state.menuByCategory[category] ?? [];
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: item.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.imageUrl!,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.fastfood),
                                  ),
                                )
                              : const Icon(Icons.fastfood),
                          title: Text(item.name),
                          subtitle: Text(
                            '${(item.price / 1000).toStringAsFixed(0)}k VND',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: Colors.orange),
                            onPressed: () {
                              context
                                  .read<FoodBloc>()
                                  .add(AddToCart(item: item));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${item.name} added to cart'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            floatingActionButton: state.cart.isEmpty
                ? null
                : FloatingActionButton.extended(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<FoodBloc>(),
                          child: const CartScreen(),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.shopping_cart),
                    label: Text('${state.cart.totalItems} items'),
                  ),
          ),
        );
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Theme.of(context).scaffoldBackgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
