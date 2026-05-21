import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
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

  void _onPickAddress() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddressPickerSheet(current: _address),
    );
    if (result != null && mounted) setState(() => _address = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _LocationPill(address: _address, onTap: _onPickAddress),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _SearchBar(),
            ),
            const SizedBox(height: 12),
            _CategoryChips(
              categories: _categories,
              selected: _selected,
              onSelect: (c) => setState(() => _selected = c),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<FoodBloc, FoodState>(
                builder: (context, state) {
                  if (state is FoodLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is FoodError) {
                    return _ErrorView(
                      message: state.message,
                      onRetry: () => context
                          .read<FoodBloc>()
                          .add(const LoadRestaurants()),
                    );
                  }
                  if (state is RestaurantListLoaded) {
                    if (state.restaurants.isEmpty) {
                      return const Center(
                        child: Text('Không tìm thấy nhà hàng'),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: state.restaurants.length,
                      itemBuilder: (context, i) => RestaurantCard(
                        restaurant: state.restaurants[i],
                        onTap: () {
                          context.read<FoodBloc>().add(
                                LoadRestaurantMenu(
                                  restaurant: state.restaurants[i],
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
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationPill extends StatelessWidget {
  final String address;
  final VoidCallback onTap;

  const _LocationPill({required this.address, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Giao tới: ',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      TextSpan(
                        text: address,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 20, color: AppColors.textSecondaryLight),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1F4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.search_rounded,
                size: 20, color: AppColors.textSecondaryLight),
          ),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: 'Tìm nhà hàng, món ăn...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Material(
              color: AppColors.surfaceLight,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {},
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(Icons.tune_rounded,
                      size: 18, color: AppColors.textPrimaryLight),
                ),
              ),
            ),
          ),
        ],
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
      height: 36,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            for (final c in categories)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _CategoryChip(
                  label: c,
                  active: c == selected,
                  onTap: () => onSelect(c),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : const Color(0xFFEFF1F4),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? Colors.white : AppColors.textSecondaryLight,
          ),
        ),
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn địa chỉ giao hàng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (final a in _saved)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.place_outlined,
                    color: AppColors.primary),
                title: Text(a,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: a == current
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(context, a),
              ),
          ],
        ),
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
            const Icon(Icons.error_outline_rounded,
                size: 64, color: AppColors.textSecondaryLight),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
