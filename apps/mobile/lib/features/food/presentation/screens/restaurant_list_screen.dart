import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../bloc/food_bloc.dart';
import '../bloc/food_event.dart';
import '../bloc/food_state.dart';
import '../widgets/restaurant_card.dart';
import 'restaurant_menu_screen.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  static const _categories = <String>[
    'Tất cả',
    'Việt Nam',
    'Cà phê',
    'Đồ ăn nhanh',
    'Bánh',
    'Healthy',
    'Đồ uống',
  ];

  String _selected = 'Tất cả';
  String _address = '123 Nguyễn Huệ, Quận 1';

  @override
  void initState() {
    super.initState();
    context.read<FoodBloc>().add(const LoadRestaurants());
  }

  Future<void> _onPickAddress() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _AddressPickerSheet(current: _address),
    );
    if (result != null && mounted) setState(() => _address = result);
  }

  void _onSelectCategory(String category) {
    setState(() => _selected = category);
    context.read<FoodBloc>().add(
          LoadRestaurants(category: category == 'Tất cả' ? null : category),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 4),
            _FoodHeader(address: _address, onTapAddress: _onPickAddress),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _SearchBar(enabled: true),
            ),
            _CategoryChips(
              categories: _categories,
              selected: _selected,
              onSelect: _onSelectCategory,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<FoodBloc, FoodState>(
                builder: (context, state) {
                  if (state is FoodLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is FoodError) {
                    return Center(
                      child: ErrorView(
                        title: 'Không thể tải nhà hàng',
                        message: state.message,
                        retryLabel: 'Thử lại',
                        onRetry: () => context.read<FoodBloc>().add(
                              LoadRestaurants(
                                category:
                                    _selected == 'Tất cả' ? null : _selected,
                              ),
                            ),
                      ),
                    );
                  }
                  if (state is! RestaurantListLoaded) {
                    return const SizedBox.shrink();
                  }

                  final restaurants = state.restaurants;
                  if (restaurants.isEmpty) {
                    return Center(
                      child: EmptyState(
                        icon: Icons.storefront_outlined,
                        title: 'Chưa có quán phù hợp',
                        subtitle:
                            'Thử đổi danh mục hoặc địa chỉ giao hàng để xem thêm gợi ý.',
                        actionLabel: 'Tải lại',
                        onAction: () => context.read<FoodBloc>().add(
                              LoadRestaurants(
                                category:
                                    _selected == 'Tất cả' ? null : _selected,
                              ),
                            ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Row(
                          children: [
                            Text(
                              '${restaurants.length} quán đang giao',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color:
                                      AppColors.borderLight.withValues(alpha: 0.8),
                                ),
                              ),
                              child: Text(
                                _selected,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 16),
                          children: [
                            for (final restaurant in restaurants)
                              RestaurantCard(
                                restaurant: restaurant,
                                onTap: () {
                                  context.read<FoodBloc>().add(
                                        LoadRestaurantMenu(
                                          restaurant: restaurant,
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
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodHeader extends StatelessWidget {
  final String address;
  final VoidCallback onTapAddress;

  const _FoodHeader({required this.address, required this.onTapAddress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTapAddress,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Giao đến',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondaryLight,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Hôm nay bạn muốn ăn gì?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Khám phá quán gần bạn với thời gian giao nhanh và ưu đãi nổi bật.',
            style: TextStyle(
              fontSize: 14,
              height: 1.35,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final bool enabled;

  const _SearchBar({required this.enabled});

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: enabled,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Tìm nhà hàng, món ăn, thức uống',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: Padding(
          padding: const EdgeInsets.all(6),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.tune_rounded, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final active = category == selected;
          return ChoiceChip(
            label: Text(category),
            selected: active,
            onSelected: (_) => onSelect(category),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              color: active ? Colors.white : AppColors.textPrimaryLight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: BorderSide(
                color: active ? AppColors.primary : AppColors.borderLight,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            backgroundColor: Colors.white,
            selectedColor: AppColors.primary,
            showCheckmark: false,
          );
        },
      ),
    );
  }
}

class _AddressPickerSheet extends StatelessWidget {
  final String current;

  const _AddressPickerSheet({required this.current});

  static const _saved = <String>[
    '123 Nguyễn Huệ, Quận 1',
    '88 Lê Lợi, Quận 1',
    'Vinhomes Central Park, Bình Thạnh',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn địa chỉ giao hàng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (final address in _saved)
              ListTile(
                contentPadding: EdgeInsets.zero,
                minVerticalPadding: 10,
                leading: const Icon(Icons.place_outlined, color: AppColors.primary),
                title: Text(
                  address,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: address == current
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(context, address),
              ),
          ],
        ),
      ),
    );
  }
}
