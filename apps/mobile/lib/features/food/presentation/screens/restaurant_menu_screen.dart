import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/skeleton_list.dart';
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
            backgroundColor: AppColors.backgroundLight,
            body: _MenuLoadingView(),
          );
        }

        if (state is FoodError) {
          return Scaffold(
            appBar: AppBar(),
            backgroundColor: AppColors.backgroundLight,
            body: Center(
              child: ErrorView(
                title: 'Không thể tải thực đơn',
                message: state.message,
                retryLabel: 'Quay lại',
                onRetry: () => Navigator.pop(context),
              ),
            ),
          );
        }

        if (state is! RestaurantMenuLoaded) {
          return const Scaffold(
            backgroundColor: AppColors.backgroundLight,
            body: Center(
              child: EmptyState(
                icon: Icons.menu_book_rounded,
                title: 'Chưa có thực đơn',
                subtitle: 'Quay lại danh sách quán để chọn địa điểm khác.',
              ),
            ),
          );
        }

        final restaurant = state.restaurant;
        final cart = state.cart;
        final categories = state.menuByCategory.keys.toList();

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 248,
                pinned: true,
                stretch: true,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                  title: Text(
                    restaurant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      shadows: [Shadow(blurRadius: 16, color: Colors.black38)],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (restaurant.imageUrl != null)
                        Image.network(
                          restaurant.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _MenuHeroFallback(
                            category: restaurant.category,
                          ),
                        )
                      else
                        _MenuHeroFallback(category: restaurant.category),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.12),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.72),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.borderLight.withValues(alpha: 0.8),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _InfoChip(
                              icon: Icons.star_rounded,
                              color: const Color(0xFFFFC107),
                              label:
                                  '${restaurant.rating.toStringAsFixed(1)} (${restaurant.totalReviews} đánh giá)',
                            ),
                            _InfoChip(
                              icon: Icons.access_time_filled_rounded,
                              color: AppColors.primary,
                              label: '${restaurant.deliveryTimeMinutes} phút',
                            ),
                            _InfoChip(
                              icon: Icons.shopping_bag_rounded,
                              color: AppColors.accent,
                              label: restaurant.minOrderAmount <= 0
                                  ? 'Không yêu cầu tối thiểu'
                                  : 'Tối thiểu ${(restaurant.minOrderAmount / 1000).toStringAsFixed(0)}k',
                            ),
                          ],
                        ),
                        if (restaurant.description != null &&
                            restaurant.description!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            restaurant.description!,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                        if (categories.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Text(
                            'Danh mục',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 40,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (context, index) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundLight,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  categories[index],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (categories.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: EmptyState(
                      icon: Icons.ramen_dining_rounded,
                      title: 'Quán chưa có món hiển thị',
                      subtitle: 'Hãy quay lại sau hoặc chọn quán khác để tiếp tục.',
                    ),
                  ),
                )
              else
                ...categories.map(
                  (category) => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),
                          ...state.menuByCategory[category]!.map((item) {
                            final quantity = cart.items
                                .where((entry) => entry.item.id == item.id)
                                .fold<int>(0, (sum, entry) => sum + entry.quantity);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _MenuItemCard(
                                item: item,
                                quantity: quantity,
                                onAdd: () => context
                                    .read<FoodBloc>()
                                    .add(AddToCart(item: item)),
                                onRemove: () => context
                                    .read<FoodBloc>()
                                    .add(RemoveFromCart(itemId: item.id)),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 104)),
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

class _MenuLoadingView extends StatelessWidget {
  const _MenuLoadingView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: const [
          SizedBox(
            height: 220,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0x1A98A2B3),
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
          ),
          SizedBox(height: 16),
          SkeletonList(itemCount: 5, itemHeight: 96, spacing: 12),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _InfoChip({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _MenuItemCard({
    required this.item,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.75)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 88,
              height: 88,
              child: item.imageUrl != null
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _MenuItemFallback(),
                    )
                  : const _MenuItemFallback(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '${(item.price / 1000).toStringAsFixed(0)}k ${item.currency}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    if (!item.isAvailable)
                      const Text(
                        'Hết món',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondaryLight,
                        ),
                      )
                    else if (quantity == 0)
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: FilledButton(
                          onPressed: onAdd,
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Icon(Icons.add_rounded),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _QtyButton(icon: Icons.remove_rounded, onTap: onRemove),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                            _QtyButton(
                              icon: Icons.add_rounded,
                              onTap: onAdd,
                              primary: true,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  const _QtyButton({required this.icon, required this.onTap, this.primary = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: primary ? AppColors.primary : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: primary ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: primary ? Colors.white : AppColors.textPrimaryLight,
        ),
      ),
    );
  }
}

class _MenuItemFallback extends StatelessWidget {
  const _MenuItemFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundLight,
      alignment: Alignment.center,
      child: const Icon(
        Icons.fastfood_rounded,
        color: AppColors.textSecondaryLight,
      ),
    );
  }
}

class _MenuHeroFallback extends StatelessWidget {
  final String category;

  const _MenuHeroFallback({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00B14F), Color(0xFF4CD787)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(24),
      alignment: Alignment.bottomLeft,
      child: Text(
        category,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  final CartModel cart;
  final VoidCallback onViewCart;

  const _CartBar({required this.cart, required this.onViewCart});

  @override
  Widget build(BuildContext context) {
    final total = cart.subtotal >= 1000
        ? '${(cart.subtotal / 1000).toStringAsFixed(0)}k'
        : cart.subtotal.toStringAsFixed(0);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: FilledButton(
          onPressed: onViewCart,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${cart.totalItems}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Xem giỏ hàng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '$total ${cart.items.isNotEmpty ? cart.items.first.item.currency : 'VND'}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
