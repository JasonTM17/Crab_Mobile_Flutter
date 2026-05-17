import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/cart_model.dart';
import '../../data/models/menu_item_model.dart';
import '../bloc/food_bloc.dart';
import '../bloc/food_event.dart';
import '../bloc/food_state.dart';
import 'cart_screen.dart';

class RestaurantMenuScreen extends StatelessWidget {
  const RestaurantMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FoodBloc, FoodState>(
      builder: (context, state) {
        if (state is FoodLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is FoodError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(state.message)),
          );
        }

        if (state is! RestaurantMenuLoaded) {
          return const Scaffold(
            body: Center(child: Text('No menu data')),
          );
        }

        final restaurant = state.restaurant;
        final cart = state.cart;
        final categories = state.menuByCategory.keys.toList();

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    restaurant.name,
                    style: const TextStyle(
                      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                    ),
                  ),
                  background: restaurant.imageUrl != null
                      ? Image.network(
                          restaurant.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Icon(Icons.restaurant, size: 64),
                          ),
                        )
                      : Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
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
                          const Icon(Icons.star,
                              color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${restaurant.rating.toStringAsFixed(1)} (${restaurant.totalReviews} reviews)',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Icon(Icons.access_time,
                              size: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            '${restaurant.deliveryTimeMinutes} min',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      if (restaurant.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          restaurant.description!,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              for (final category in categories) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      category,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item =
                            state.menuByCategory[category]![index];
                        final qty = cart.items
                            .where((ci) => ci.item.id == item.id)
                            .fold(0, (sum, ci) => sum + ci.quantity);
                        return _MenuItemTile(
                          item: item,
                          quantity: qty,
                          onAdd: () => context
                              .read<FoodBloc>()
                              .add(AddToCart(item: item)),
                          onRemove: () => context
                              .read<FoodBloc>()
                              .add(RemoveFromCart(itemId: item.id)),
                        );
                      },
                      childCount:
                          state.menuByCategory[category]!.length,
                    ),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
          bottomNavigationBar: cart.isEmpty
              ? null
              : _CartBar(
                  cart: cart,
                  onViewCart: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<FoodBloc>(),
                          child: const CartScreen(),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final MenuItemModel item;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _MenuItemTile({
    required this.item,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}k';
    }
    return price.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.imageUrl != null
                ? Image.network(
                    item.imageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _ItemPlaceholder(
                      size: 80,
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                  )
                : _ItemPlaceholder(
                    size: 80,
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                if (item.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '${_formatPrice(item.price)} ${item.currency}',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!item.isAvailable)
            Text(
              'Unavailable',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            )
          else if (quantity == 0)
            FilledButton.tonal(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                minimumSize: const Size(36, 36),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Icon(Icons.add, size: 20),
            )
          else
            Row(
              children: [
                _QtyButton(icon: Icons.remove, onTap: onRemove),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '$quantity',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _QtyButton(icon: Icons.add, onTap: onAdd),
              ],
            ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _ItemPlaceholder extends StatelessWidget {
  final double size;
  final Color color;

  const _ItemPlaceholder({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: color,
      child: Icon(
        Icons.fastfood,
        size: size * 0.4,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  final CartModel cart;
  final VoidCallback onViewCart;

  const _CartBar({required this.cart, required this.onViewCart});

  String _formatPrice(double price) {
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}k';
    return price.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: FilledButton(
          onPressed: onViewCart,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${cart.totalItems}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'View Cart',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                '${_formatPrice(cart.subtotal)} ${cart.items.isNotEmpty ? cart.items.first.item.currency : "VND"}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
