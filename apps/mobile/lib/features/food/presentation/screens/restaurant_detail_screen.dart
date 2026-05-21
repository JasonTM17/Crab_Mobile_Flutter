import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
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
    final thousand = (value / 1000).toStringAsFixed(0);
    return '$thousand.000đ';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FoodBloc, FoodState>(
      builder: (context, state) {
        if (state is FoodLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (state is! RestaurantMenuLoaded) {
          return const Scaffold(body: Center(child: Text('Lỗi tải dữ liệu')));
        }

        final restaurant = state.restaurant;
        final categories = state.menuByCategory.keys.toList();

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                floating: false,
                stretch: true,
                backgroundColor: AppColors.surfaceLight,
                surfaceTintColor: AppColors.surfaceLight,
                elevation: 0,
                leading: _RoundIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                actions: [
                  _RoundIconButton(
                    icon: _favorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    iconColor: _favorite ? AppColors.accent : null,
                    onTap: () => setState(() => _favorite = !_favorite),
                  ),
                  const SizedBox(width: 8),
                ],
                title: Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                centerTitle: false,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  stretchModes: const [StretchMode.zoomBackground],
                  background: _HeroBackground(imageUrl: restaurant.imageUrl),
                  title: const SizedBox.shrink(),
                ),
              ),
            ],
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                _InfoCard(
                  name: restaurant.name,
                  category: restaurant.category,
                  description: restaurant.description,
                  rating: restaurant.rating,
                  reviews: restaurant.totalReviews,
                  isOpen: restaurant.isOpen,
                  deliveryMinutes: restaurant.deliveryTimeMinutes,
                  minOrderText: _formatVnd(restaurant.minOrderAmount),
                ),
                const SizedBox(height: 16),
                if (categories.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text(
                        'Không có món',
                        style:
                            TextStyle(color: AppColors.textSecondaryLight),
                      ),
                    ),
                  )
                else
                  for (final category in categories) ...[
                    _CategoryHeader(label: category),
                    const SizedBox(height: 8),
                    for (final item in state.menuByCategory[category] ?? [])
                      _MenuItemCard(
                        name: item.name,
                        priceText: _formatVnd(item.price),
                        imageUrl: item.imageUrl,
                        onAdd: () {
                          context.read<FoodBloc>().add(AddToCart(item: item));
                        },
                      ),
                    const SizedBox(height: 8),
                  ],
              ],
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
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_bag_rounded),
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '${state.cart.totalItems}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  label: const Text(
                    'Xem giỏ hàng',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
        );
      },
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.white.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              icon,
              size: 18,
              color: iconColor ?? AppColors.textPrimaryLight,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroBackground extends StatelessWidget {
  final String? imageUrl;
  const _HeroBackground({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl != null)
          CachedNetworkImage(
            imageUrl: imageUrl!,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: AppColors.borderLight.withValues(alpha: 0.4),
            ),
            errorWidget: (_, __, ___) => const _ImageFallback(),
          )
        else
          const _ImageFallback(),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Color(0x33000000),
                Color(0x88000000),
              ],
              stops: [0.5, 0.8, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFB347), Color(0xFFFFCC70)],
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

class _InfoCard extends StatelessWidget {
  final String name;
  final String category;
  final String? description;
  final double rating;
  final int reviews;
  final bool isOpen;
  final int deliveryMinutes;
  final String minOrderText;

  const _InfoCard({
    required this.name,
    required this.category,
    required this.description,
    required this.rating,
    required this.reviews,
    required this.isOpen,
    required this.deliveryMinutes,
    required this.minOrderText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            category,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoStat(
                icon: Icons.star_rounded,
                iconColor: const Color(0xFFFFC107),
                label: '${rating.toStringAsFixed(1)} ($reviews)',
              ),
              const SizedBox(width: 16),
              _InfoStat(
                icon: Icons.access_time_rounded,
                iconColor: AppColors.textSecondaryLight,
                label: isOpen ? 'Mở · $deliveryMinutes phút' : 'Đóng cửa',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.shopping_basket_rounded,
                  size: 16, color: AppColors.textSecondaryLight),
              const SizedBox(width: 6),
              Text(
                'Đơn tối thiểu $minOrderText',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: AppColors.borderLight.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              description!,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _InfoStat({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String label;
  const _CategoryHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimaryLight,
        ),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final String name;
  final String priceText;
  final String? imageUrl;
  final VoidCallback onAdd;

  const _MenuItemCard({
    required this.name,
    required this.priceText,
    required this.imageUrl,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 72,
              height: 72,
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color:
                            AppColors.borderLight.withValues(alpha: 0.4),
                      ),
                      errorWidget: (_, __, ___) => const _ItemFallback(),
                    )
                  : const _ItemFallback(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  priceText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
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
      child: const Icon(Icons.fastfood_rounded,
          color: AppColors.textSecondaryLight),
    );
  }
}
