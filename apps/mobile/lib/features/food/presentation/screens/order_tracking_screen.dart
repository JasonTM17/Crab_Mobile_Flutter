import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_motion.dart';
import '../../data/models/order_model.dart';
import '../bloc/food_bloc.dart';
import '../bloc/food_event.dart';
import '../bloc/food_state.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String? orderId;

  const OrderTrackingScreen({super.key, this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    final orderId = widget.orderId;
    if (orderId != null && orderId.isNotEmpty) {
      context.read<FoodBloc>().add(LoadOrder(orderId: orderId));
    }
  }

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
            title: const Text(
              'Order Tracking',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              if (!isCancelled && !isDelivered)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Text('Cancel order?'),
                          content: const Text(
                            'You can still cancel before the restaurant accepts. Charges will be refunded.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Keep order'),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(context);
                                context.read<FoodBloc>().add(
                                      CancelOrder(orderId: order.id),
                                    );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444),
                              ),
                              child: const Text('Cancel order'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFFEF4444),
                      size: 18,
                    ),
                    label: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status card
                _StatusCard(order: order),
                const SizedBox(height: 20),
                // Progress stepper
                if (!isCancelled) _OrderStepper(status: order.status),
                if (isCancelled)
                  _CancelledBanner(onDone: () => Navigator.pop(context)),
                const SizedBox(height: 20),
                // Order details
                _OrderDetailsCard(order: order),
                const SizedBox(height: 20),
                // Price summary
                _PriceSummaryCard(order: order),
                const SizedBox(height: 24),
                if (isDelivered)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
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
    final isCancelled = order.status == OrderStatus.cancelled;
    final isDelivered = order.status == OrderStatus.delivered;

    LinearGradient gradient;
    Color shadowColor;
    IconData statusIcon;
    if (isCancelled) {
      gradient = const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFFB923C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      shadowColor = const Color(0xFFEF4444);
      statusIcon = Icons.cancel_rounded;
    } else if (isDelivered) {
      gradient = AppGradients.primary;
      shadowColor = const Color(0xFF00B14F);
      statusIcon = Icons.check_circle_rounded;
    } else {
      gradient = AppGradients.sunset;
      shadowColor = const Color(0xFFFB923C);
      statusIcon = Icons.delivery_dining_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(statusIcon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.status.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                if (order.estimatedMinutes != null &&
                    !isCancelled &&
                    !isDelivered) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ETA ${order.estimatedMinutes} min',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  '#${order.id.substring(0, 8).toUpperCase()}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
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
    (OrderStatus.pending, Icons.receipt_long_rounded, 'Order Placed'),
    (OrderStatus.confirmed, Icons.check_circle_rounded, 'Confirmed'),
    (OrderStatus.preparing, Icons.restaurant_rounded, 'Preparing'),
    (
      OrderStatus.outForDelivery,
      Icons.delivery_dining_rounded,
      'Out for Delivery',
    ),
    (OrderStatus.delivered, Icons.home_rounded, 'Delivered'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currentStep = status.step;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < _steps.length; i++) ...[
            Row(
              children: [
                _StepDot(
                  icon: _steps[i].$2,
                  done: i < currentStep,
                  current: i == currentStep,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _steps[i].$3,
                        style: TextStyle(
                          fontWeight: i == currentStep
                              ? FontWeight.w800
                              : i < currentStep
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                          color: i <= currentStep
                              ? cs.onSurface
                              : cs.onSurfaceVariant,
                          fontSize: 15,
                        ),
                      ),
                      if (i == currentStep) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _PulsingDot(color: cs.primary),
                            const SizedBox(width: 6),
                            Text(
                              'In progress',
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (i < _steps.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 19, top: 4, bottom: 4),
                child: AnimatedContainer(
                  duration: AppMotion.normal,
                  width: 2,
                  height: 22,
                  color: i < currentStep
                      ? cs.primary
                      : cs.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.icon,
    required this.done,
    required this.current,
  });
  final IconData icon;
  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: AppMotion.normal,
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: (done || current) ? AppGradients.primary : null,
        color: (done || current)
            ? null
            : cs.surfaceContainerHighest.withValues(alpha: 0.5),
        shape: BoxShape.circle,
        boxShadow: current
            ? [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.36),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Icon(
        icon,
        size: 20,
        color: (done || current) ? Colors.white : cs.onSurfaceVariant,
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});
  final Color color;
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.5 + 0.5 * _c.value),
          shape: BoxShape.circle,
        ),
      ),
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
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.info_rounded,
              color: Color(0xFFEF4444),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Your order was cancelled. Any charges will be refunded within 3-5 business days.',
              style: TextStyle(
                color: Color(0xFF991B1B),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
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
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.restaurant_rounded,
                  size: 20,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  order.restaurantName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${item.quantity}×',
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item.name, style: theme.textTheme.bodyMedium),
                  ),
                  Text(
                    _formatPrice(item.subtotal, order.currency),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: cs.outlineVariant.withValues(alpha: 0.4), height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 16,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.35,
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
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _Row(label: 'Subtotal', value: _fmt(order.subtotal)),
          const SizedBox(height: 10),
          _Row(label: 'Delivery fee', value: _fmt(order.deliveryFee)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              height: 1,
              color: cs.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          _Row(label: 'Total', value: _fmt(order.total), bold: true),
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
