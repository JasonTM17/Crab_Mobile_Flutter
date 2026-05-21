import 'package:flutter/material.dart';

import '../../data/models/order_model.dart';

class OrderStatusStepper extends StatelessWidget {
  final OrderStatus currentStatus;

  const OrderStatusStepper({super.key, required this.currentStatus});

  static const _steps = [
    _StepData(OrderStatus.pending, 'Order Placed', Icons.receipt_long),
    _StepData(OrderStatus.confirmed, 'Confirmed', Icons.check_circle),
    _StepData(OrderStatus.preparing, 'Preparing', Icons.restaurant),
    _StepData(OrderStatus.readyForPickup, 'Ready', Icons.takeout_dining),
    _StepData(
        OrderStatus.outForDelivery, 'Out for Delivery', Icons.delivery_dining),
    _StepData(OrderStatus.delivered, 'Delivered', Icons.home),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _steps.indexWhere((s) => s.status == currentStatus);

    return Column(
      children: List.generate(_steps.length, (index) {
        final step = _steps[index];
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? Colors.green : Colors.grey.shade200,
                  ),
                  child: Icon(
                    step.icon,
                    size: 16,
                    color: isCompleted ? Colors.white : Colors.grey,
                  ),
                ),
                if (index < _steps.length - 1)
                  Container(
                    width: 2,
                    height: 32,
                    color: isCompleted ? Colors.green : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  step.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _StepData {
  final OrderStatus status;
  final String label;
  final IconData icon;

  const _StepData(this.status, this.label, this.icon);
}
