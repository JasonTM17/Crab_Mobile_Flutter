import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../data/models/cart_model.dart';
import '../bloc/food_bloc.dart';
import '../bloc/food_event.dart';
import '../bloc/food_state.dart';
import 'order_tracking_screen.dart';

enum _PaymentMethod { wallet, cod, bank }

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _addressController = TextEditingController(
    text: '123 Nguyễn Huệ, Quận 1, TP.HCM',
  );
  final _promoController = TextEditingController();

  _PaymentMethod _payment = _PaymentMethod.wallet;

  @override
  void dispose() {
    _addressController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  String _formatVnd(double value) {
    if (value <= 0) return '0đ';
    final thousand = (value / 1000).toStringAsFixed(0);
    return '$thousand.000đ';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FoodBloc, FoodState>(
      listener: (context, state) {
        if (state is OrderTracking) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<FoodBloc>(),
                child: const OrderTrackingScreen(),
              ),
            ),
          );
        } else if (state is FoodError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final cart = switch (state) {
          RestaurantMenuLoaded s => s.cart,
          RestaurantListLoaded s => s.cart,
          OrderPlacing s => s.cart,
          _ => null,
        };

        if (cart == null || cart.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              title: const Text(
                'Giỏ hàng',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
            body: const EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Giỏ hàng trống',
              subtitle: 'Hãy chọn nhà hàng và thêm món để tiếp tục.',
            ),
          );
        }

        final isPlacing = state is OrderPlacing;
        const deliveryFee = 15000.0;
        final total = cart.subtotal + deliveryFee;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: const Text(
              'Giỏ hàng',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            elevation: 0,
            scrolledUnderElevation: 0,
            actions: [
              TextButton.icon(
                onPressed: isPlacing
                    ? null
                    : () => context.read<FoodBloc>().add(const ClearCart()),
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.error),
                label: const Text(
                  'Xoá',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              const SectionHeader(
                title: 'Món đã chọn',
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: AppSpacing.sm),
              _ItemsCard(
                cart: cart,
                onAdd: (item) =>
                    context.read<FoodBloc>().add(AddToCart(item: item)),
                onRemove: (id) =>
                    context.read<FoodBloc>().add(RemoveFromCart(itemId: id)),
                formatPrice: _formatVnd,
              ),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(
                title: 'Giao hàng',
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: AppSpacing.sm),
              _AddressCard(controller: _addressController),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(
                title: 'Thanh toán',
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: AppSpacing.sm),
              _PaymentCard(
                selected: _payment,
                onSelect: (m) => setState(() => _payment = m),
              ),
              const SizedBox(height: AppSpacing.sm),
              _PromoCard(controller: _promoController),
              const SizedBox(height: AppSpacing.lg),
              const SectionHeader(
                title: 'Tóm tắt đơn hàng',
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: AppSpacing.sm),
              _SummaryCard(
                subtotal: _formatVnd(cart.subtotal),
                deliveryFee: _formatVnd(deliveryFee),
                total: _formatVnd(total),
              ),
            ],
          ),
          bottomNavigationBar: _CheckoutBar(
            totalText: _formatVnd(total),
            loading: isPlacing,
            onPlace: () {
              context.read<FoodBloc>().add(
                    PlaceOrder(
                      deliveryAddress: _addressController.text.trim(),
                    ),
                  );
            },
          ),
        );
      },
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _CardShell({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: padding,
      child: child,
    );
  }
}

class _ItemsCard extends StatelessWidget {
  final dynamic cart;
  final void Function(dynamic item) onAdd;
  final void Function(String id) onRemove;
  final String Function(double) formatPrice;

  const _ItemsCard({
    required this.cart,
    required this.onAdd,
    required this.onRemove,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final items = cart.items as List<CartItemModel>;
    return _CardShell(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cart.restaurantName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.restaurant_rounded,
                        size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      cart.restaurantName as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          for (final ci in items)
            _CartItemRow(
              cartItem: ci,
              priceText: formatPrice(ci.subtotal),
              onAdd: () => onAdd(ci.item),
              onRemove: () => onRemove(ci.item.id),
            ),
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItemModel cartItem;
  final String priceText;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _CartItemRow({
    required this.cartItem,
    required this.priceText,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  priceText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          _QtyStepper(
            quantity: cartItem.quantity,
            onAdd: onAdd,
            onRemove: onRemove,
          ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _QtyStepper({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1F4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(icon: Icons.remove_rounded, onTap: onRemove),
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
          _StepBtn(icon: Icons.add_rounded, onTap: onAdd, primary: true),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  const _StepBtn({
    required this.icon,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: primary ? AppColors.primary : AppColors.surfaceLight,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: primary ? Colors.white : AppColors.textPrimaryLight,
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final TextEditingController controller;
  const _AddressCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              const Text(
                'Giao đến',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Sửa',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimaryLight,
            ),
            decoration: const InputDecoration(
              isDense: true,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final _PaymentMethod selected;
  final ValueChanged<_PaymentMethod> onSelect;

  const _PaymentCard({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phương thức thanh toán',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          _PaymentTile(
            icon: Icons.account_balance_wallet_rounded,
            iconBg: AppColors.primary,
            title: 'Ví Crab',
            subtitle: 'Thanh toán nhanh không tiền mặt',
            value: _PaymentMethod.wallet,
            group: selected,
            onSelect: onSelect,
          ),
          _PaymentTile(
            icon: Icons.payments_rounded,
            iconBg: AppColors.warning,
            title: 'Tiền mặt khi nhận',
            subtitle: 'Trả khi tài xế giao đến',
            value: _PaymentMethod.cod,
            group: selected,
            onSelect: onSelect,
          ),
          _PaymentTile(
            icon: Icons.account_balance_rounded,
            iconBg: AppColors.info,
            title: 'Thẻ ngân hàng',
            subtitle: 'Visa, Mastercard, ATM nội địa',
            value: _PaymentMethod.bank,
            group: selected,
            onSelect: onSelect,
          ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final _PaymentMethod value;
  final _PaymentMethod group;
  final ValueChanged<_PaymentMethod> onSelect;

  const _PaymentTile({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.group,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == group;
    return InkWell(
      onTap: () => onSelect(value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconBg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            _Radio(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  final bool selected;
  const _Radio({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.borderLight,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

class _PromoCard extends StatelessWidget {
  final TextEditingController controller;
  const _PromoCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      child: Row(
        children: [
          const Icon(Icons.local_offer_rounded,
              size: 18, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: 'Mã khuyến mãi',
                hintStyle: TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 14,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 40),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Áp dụng'),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String subtotal;
  final String deliveryFee;
  final String total;

  const _SummaryCard({
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        children: [
          _SummaryRow(label: 'Tạm tính', value: subtotal),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Phí giao hàng', value: deliveryFee),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              height: 1,
              color: AppColors.borderLight.withValues(alpha: 0.6),
            ),
          ),
          _SummaryRow(label: 'Tổng cộng', value: total, bold: true),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 16 : 14,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            color: bold
                ? AppColors.textPrimaryLight
                : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 18 : 14,
            fontWeight: FontWeight.w800,
            color: bold ? AppColors.primary : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final String totalText;
  final bool loading;
  final VoidCallback onPlace;

  const _CheckoutBar({
    required this.totalText,
    required this.loading,
    required this.onPlace,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          border: Border(
            top: BorderSide(
              color: AppColors.borderLight.withValues(alpha: 0.6),
            ),
          ),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'TỔNG',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  totalText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _PlaceOrderButton(
                label: 'Đặt đơn $totalText',
                loading: loading,
                onTap: loading ? null : onPlace,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceOrderButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onTap;

  const _PlaceOrderButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.4,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }
}
