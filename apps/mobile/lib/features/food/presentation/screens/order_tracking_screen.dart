import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/order_model.dart';
import '../bloc/food_bloc.dart';
import '../bloc/food_event.dart';
import '../bloc/food_state.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FoodBloc, FoodState>(
      builder: (context, state) {
        if (state is! OrderTracking) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final order = state.order;
        final isCancelled = order.status == OrderStatus.cancelled;
        final isDelivered = order.status == OrderStatus.delivered;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Order Tracking'),
            automaticallyImplyLeading: false,
            actions: [
              if (!isCancelled && !isDelivered)
                TextButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Cancel Order?'),
                        content: const Text(
                            'Are you sure you want to cancel this order?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('No'),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                              context
                                  .read<FoodBloc>()
                                  .add(CancelOrder(orderId: order.id));
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Cancel Order'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusCard(order: order),
                const SizedBox(height: 20),
                if (!isCancelled) _OrderStepper(status: order.status),
                if (isCancelled)
                  _CancelledBanner(onDone: () => Navigator.pop(context)),
                const SizedBox(height: 20),
                _OrderDetailsCard(order: order),
                const SizedBox(height: 20),
                _PriceSummaryCard(order: order),
                const SizedBox(height: 24),
                if (isDelivered)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  final OrderModel order;

  const _StatusCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCancelled = order.status == OrderStatus.cancelled;
    final isDelivered = order.status == OrderStatus.delivered;

    Color statusColor;
    IconData statusIcon;
    if (isCancelled) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel_outlined;
    } else if (isDelivered) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
    } else {
      statusColor = theme.colorScheme.primary;
      statusIcon = Icons.delivery_dining;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.status.label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                if (order.estimatedMinutes != null && !isCancelled && !isDelivered) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Estimated: ${order.estimatedMinutes} min',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Order #${order.id.substring(0, 8).toUpperCase()}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderStepper extends StatelessWidget {
  final OrderStatus status;

  const _OrderStepper({required this.status});

  static const _steps = [
    (OrderStatus.pending, Icons.receipt_outlined, 'Order Placed'),
    (OrderStatus.confirmed, Icons.check_circle_outline, 'Confirmed'),
    (OrderStatus.preparing, Icons.restaurant, 'Preparing'),
    (OrderStatus.outForDelivery, Icons.delivery_dining, 'Out for Delivery'),
    (OrderStatus.delivered, Icons.home, 'Delivered'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStep = status.step;

    return Column(
      children: [
        for (int i = 0; i < _steps.length; i++) ...[
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= currentStep
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                ),
                child: Icon(
                  _steps[i].$2,
                  size: 20,
                  color: i <= currentStep
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _steps[i].$3,
                style: TextStyle(
                  fontWeight: i == currentStep
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: i <= currentStep
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (i == currentStep) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Current',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (i < _steps.length - 1)
            Padding(
              padding: const EdgeInsets.only(left: 19),
              child: Container(
                width: 2,
                height: 24,
                color: i < currentStep
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
              ),
            ),
        ],
      ],
    );
  }
}

class _CancelledBanner extends StatelessWidget {
  final VoidCallback onDone;

  const _CancelledBanner({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.red),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Your order has been cancelled. Any charges will be refunded.',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetailsCard extends StatelessWidget {
  final OrderModel order;

  const _OrderDetailsCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant, size: 18),
              const SizedBox(width: 8),
              Text(
                order.restaurantName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 20),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(
                      '${item.quantity}×',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.name)),
                    Text(
                      _formatPrice(item.subtotal, order.currency),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )),
          const Divider(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price, String currency) {
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}k $currency';
    return '${price.toStringAsFixed(0)} $currency';
  }
}

class _PriceSummaryCard extends StatelessWidget {
  final OrderModel order;

  const _PriceSummaryCard({required this.order});

  String _fmt(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}k ${order.currency}';
    }
    return '${price.toStringAsFixed(0)} ${order.currency}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          _Row(label: 'Subtotal', value: _fmt(order.subtotal)),
          const SizedBox(height: 8),
          _Row(label: 'Delivery fee', value: _fmt(order.deliveryFee)),
          const Divider(height: 20),
          _Row(
            label: 'Total',
            value: _fmt(order.total),
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _Row({required this.label, required this.value, this.bold = false});

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
