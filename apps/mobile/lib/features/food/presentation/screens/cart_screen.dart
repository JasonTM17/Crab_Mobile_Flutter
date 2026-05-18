import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            appBar: AppBar(title: const Text('Cart')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your cart is empty',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
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
            title: const Text('Your Cart'),
            actions: [
              TextButton(
                onPressed: isPlacing
                    ? null
                    : () => context.read<FoodBloc>().add(const ClearCart()),
                child: const Text('Clear'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant name
                if (cart.restaurantName != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.restaurant, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        cart.restaurantName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                // Cart items
                ...cart.items.map((ci) => _CartItemRow(
                      cartItem: ci,
                      onAdd: () => context
                          .read<FoodBloc>()
                          .add(AddToCart(item: ci.item)),
                      onRemove: () => context
                          .read<FoodBloc>()
                          .add(RemoveFromCart(itemId: ci.item.id)),
                    )),
                const SizedBox(height: 24),
                // Delivery address
                Text(
                  'Delivery Address',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                // Order summary
                Text(
                  'Order Summary',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _SummaryRow(
                  label: 'Subtotal',
                  value: _formatPrice(cart.subtotal, currency),
                ),
                const SizedBox(height: 8),
                _SummaryRow(
                  label: 'Delivery fee',
                  value: _formatPrice(deliveryFee, currency),
                ),
                const Divider(height: 24),
                _SummaryRow(
                  label: 'Total',
                  value: _formatPrice(total, currency),
                  bold: true,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: FilledButton(
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
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isPlacing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Place Order · ${_formatPrice(total, currency)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Qty controls
          Row(
            children: [
              _QtyBtn(icon: Icons.remove, onTap: onRemove),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '${cartItem.quantity}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              _QtyBtn(icon: Icons.add, onTap: onAdd),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              cartItem.item.name,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          Text(
            '${_formatPrice(cartItem.subtotal)} ${cartItem.item.currency}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16),
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
    final style = bold
        ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        : null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
