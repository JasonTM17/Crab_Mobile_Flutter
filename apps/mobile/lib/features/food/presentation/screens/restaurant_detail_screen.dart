import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/info_chip.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/skeleton_list.dart';
import '../../data/models/menu_item_model.dart';
import '../bloc/food_bloc.dart';
import '../bloc/food_event.dart';
import '../bloc/food_state.dart';
import 'cart_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({super.key});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  bool _favorite = false;

  String _formatVnd(double value) {
    if (value <= 0) return 'Miễn phí';
    return '${(value / 1000).toStringAsFixed(0)}k';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FoodBloc, FoodState>(
      builder: (context, state) {
        if (state is FoodLoading) {
          return const Scaffold(
            backgroundColor: AppColors.backgroundLight,
            body: _RestaurantDetailLoadingView(),
          );
        }

        if (state is FoodError) {
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(),
            body: Center(
              child: ErrorView(
                title: 'Không thể tải trang quán',
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
                icon: Icons.storefront_outlined,
                title: 'Quán chưa sẵn sàng',
                subtitle: 'Hãy quay lại danh sách để chọn địa điểm khác.',
              ),
            ),
          );
        }

        final restaurant = state.restaurant;
        final cart = state.cart;
        final entries = state.menuByCategory.entries.toList();

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 252,
                pinned: true,
                stretch: true,
                elevation: 0,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                leading: _HeroActionButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                actions: [
                  _HeroActionButton(
                    icon: _favorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    iconColor: _favorite ? AppColors.accent : null,
                    onTap: () => setState(() => _favorite = !_favorite),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
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
                      shadows: [Shadow(blurRadius: 16, color: Colors.black45)],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (restaurant.imageUrl != null)
                        CachedNetworkImage(
                          imageUrl: restaurant.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const _HeroFallback(),
                        )
                      else
                        const _HeroFallback(),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.12),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.74),
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            if (restaurant.description?.isNotEmpty ?? false)
                              Text(
                                restaurant.description!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondaryLight,
                                      height: 1.4,
                                    ),
                              ),
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              spacing: AppSpacing.xs,
                              runSpacing: AppSpacing.xs,
                              children: [
                                InfoChip(
                                  label: restaurant.category,
                                  icon: Icons.local_dining_rounded,
                                ),
                                InfoChip(
                                  label:
                                      '${restaurant.rating.toStringAsFixed(1)} • ${restaurant.totalReviews} đánh giá',
                                  icon: Icons.star_rounded,
                                  variant: InfoChipVariant.warning,
                                ),
                                InfoChip(
                                  label: restaurant.isOpen ? 'Đang mở' : 'Tạm đóng',
                                  icon: restaurant.isOpen
                                      ? Icons.check_circle_rounded
                                      : Icons.pause_circle_rounded,
                                  variant: restaurant.isOpen
                                      ? InfoChipVariant.success
                                      : InfoChipVariant.error,
                                ),
                                InfoChip(
                                  label: '${restaurant.deliveryTimeMinutes} phút',
                                  icon: Icons.schedule_rounded,
                                  variant: InfoChipVariant.brand,
                                ),
                                InfoChip(
                                  label: restaurant.minOrderAmount <= 0
                                      ? 'Không yêu cầu tối thiểu'
                                      : 'Tối thiểu ${_formatVnd(restaurant.minOrderAmount)}',
                                  icon: Icons.shopping_bag_outlined,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const SectionHeader(
                        title: 'Thực đơn',
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (entries.isEmpty)
                        const EmptyState(
                          icon: Icons.ramen_dining_rounded,
                          title: 'Quán chưa có món hiển thị',
                          subtitle: 'Hãy quay lại sau hoặc chọn quán khác để tiếp tục.',
                          compact: true,
                        )
                      else
                        for (final entry in entries) ...[
                          SectionHeader(
                            title: entry.key,
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                          ),
                          for (final item in entry.value)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _MenuItemCard(
                                item: item,
                                quantity: cart.items
                                    .where((row) => row.item.id == item.id)
                                    .fold<int>(0, (sum, row) => sum + row.quantity),
                                priceText: '${_formatVnd(item.price)} ${item.currency}',
                                onAdd: () => context
                                    .read<FoodBloc>()
                                    .add(AddToCart(item: item)),
                                onRemove: () => context
                                    .read<FoodBloc>()
                                    .add(RemoveFromCart(itemId: item.id)),
                              ),
                            ),
                        ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: cart.isEmpty
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: GradientButton(
                      label:
                          'Xem giỏ hàng • ${cart.totalItems} món • ${_formatVnd(cart.subtotal)} ${cart.items.first.item.currency}',
                      icon: Icons.shopping_bag_rounded,
                      height: 60,
                      borderRadius: AppRadii.lg,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<FoodBloc>(),
                            child: const CartScreen(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _HeroActionButton extends StatelessWidget {
  const _HeroActionButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Material(
        color: Colors.white.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: iconColor ?? AppColors.textPrimaryLight),
          ),
        ),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({
    required this.item,
    required this.quantity,
    required this.priceText,
    required this.onAdd,
    required this.onRemove,
  });

  final MenuItemModel item;
  final int quantity;
  final String priceText;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: SizedBox(
              width: 84,
              height: 84,
              child: item.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const _ItemFallback(),
                    )
                  : const _ItemFallback(),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (item.description?.isNotEmpty ?? false) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                          height: 1.35,
                        ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      priceText,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const Spacer(),
                    if (!item.isAvailable)
                      const InfoChip(
                        label: 'Hết món',
                        icon: Icons.block_rounded,
                        variant: InfoChipVariant.error,
                        dense: true,
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
                              borderRadius: BorderRadius.circular(AppRadii.md),
                            ),
                          ),
                          child: const Icon(Icons.add_rounded),
                        ),
                      )
                    else
                      _QuantityPill(
                        quantity: quantity,
                        onAdd: onAdd,
                        onRemove: onRemove,
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

class _QuantityPill extends StatelessWidget {
  const _QuantityPill({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, VoidCallback onTap, {bool primary = false}) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(Icons.remove_rounded, onRemove),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$quantity',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          button(Icons.add_rounded, onAdd, primary: true),
        ],
      ),
    );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback();

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
      child: const Center(
        child: Icon(Icons.restaurant_rounded, size: 80, color: Colors.white),
      ),
    );
  }
}

class _ItemFallback extends StatelessWidget {
  const _ItemFallback();

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

class _RestaurantDetailLoadingView extends StatelessWidget {
  const _RestaurantDetailLoadingView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: const [
          SizedBox(
            height: 236,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0x1A98A2B3),
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
          ),
          SizedBox(height: 16),
          SkeletonList(itemCount: 5, itemHeight: 100, spacing: 12),
        ],
      ),
    );
  }
}
