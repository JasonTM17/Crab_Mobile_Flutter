import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../data/models/cart_model.dart';
import '../bloc/food_bloc.dart';
import '../bloc/food_event.dart';
import '../bloc/food_state.dart';
import 'order_tracking_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _addressController = TextEditingController(
    text: '123 Nguyen Hue, District 1, HCMC',
  );

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  String _formatPrice(double price, String currency) {
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}k $currency';
    return '${price.toStringAsFixed(0)} $currency';
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
              backgroundColor: Colors.red,
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
            appBar: AppBar(
              title: const Text(
                'Cart',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
            body: const EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              subtitle: 'Browse restaurants and add items to get started.',
            ),
          );
        }

        final isPlacing = state is OrderPlacing;
        final currency =
            cart.items.isNotEmpty ? cart.items.first.item.currency : 'VND';
        const deliveryFee = 15000.0;
        final total = cart.subtotal + deliveryFee;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Your cart',
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
                    size: 18, color: Color(0xFFEF4444)),
                label: const Text(
                  'Clear',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant name
                if (cart.restaurantName != null) ...[
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.restaurant_rounded,
                              size: 18, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ordering from',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Text(
                                cart.restaurantName!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: cart.items
                        .map((ci) => _CartItemRow(
                              cartItem: ci,
                              onAdd: () => context
                                  .read<FoodBloc>()
                                  .add(AddToCart(item: ci.item)),
                              onRemove: () => context.read<FoodBloc>().add(
                                  RemoveFromCart(itemId: ci.item.id)),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Delivery address',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      prefixIcon:
                          Icon(Icons.location_on_rounded, size: 20),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 14,
                      ),
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Order summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(
                        label: 'Subtotal',
                        value: _formatPrice(cart.subtotal, currency),
                      ),
                      const SizedBox(height: 10),
                      _SummaryRow(
                        label: 'Delivery fee',
                        value: _formatPrice(deliveryFee, currency),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Container(
                          height: 1,
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      _SummaryRow(
                        label: 'Total',
                        value: _formatPrice(total, currency),
                        bold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: GradientButton(
                label: 'Place order · ${_formatPrice(total, currency)}',
                icon: Icons.flash_on_rounded,
                height: 56,
                onPressed: isPlacing
                    ? null
                    : () {
                        context.read<FoodBloc>().add(
                              PlaceOrder(
                                deliveryAddress:
                                    _addressController.text.trim(),
                              ),
                            );
                      },
                loading: isPlacing,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItemModel cartItem;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _CartItemRow({
    required this.cartItem,
    required this.onAdd,
    required this.onRemove,
  });

  String _formatPrice(double price) {
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}k';
    return price.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                _QtyBtn(icon: Icons.remove_rounded, onTap: onRemove),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '${cartItem.quantity}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                _QtyBtn(icon: Icons.add_rounded, onTap: onAdd),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              cartItem.item.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${_formatPrice(cartItem.subtotal)} ${cartItem.item.currency}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.30),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
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
    final theme = Theme.of(context);
    final labelStyle = bold
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)
        : theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          );
    final valueStyle = bold
        ? theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.primary,
          )
        : theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}
