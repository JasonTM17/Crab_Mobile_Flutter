import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/skeleton_list.dart';
import '../../data/models/order_model.dart';
import '../bloc/food_bloc.dart';
import '../bloc/food_event.dart';
import '../bloc/food_state.dart';
import 'order_tracking_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FoodBloc>().add(const LoadOrderHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Lịch sử đơn món',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.backgroundLight,
      ),
      body: BlocBuilder<FoodBloc, FoodState>(
        builder: (context, state) {
          if (state is FoodLoading) {
            return const SkeletonList(
              itemCount: 6,
              itemHeight: 110,
              padding: EdgeInsets.all(16),
            );
          }
          if (state is FoodError) {
            return EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Không tải được đơn hàng',
              subtitle: state.message,
              actionLabel: 'Thử lại',
              onAction: () =>
                  context.read<FoodBloc>().add(const LoadOrderHistory()),
            );
          }
          if (state is OrderHistoryLoaded) {
            final orders = state.orders;
            if (orders.isEmpty) {
              return const EmptyState(
                icon: Icons.restaurant_menu_rounded,
                title: 'Chưa có đơn món',
                subtitle:
                    'Các đơn đã đặt sẽ xuất hiện tại đây để bạn theo dõi lại.',
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<FoodBloc>().add(const LoadOrderHistory());
              },
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _OrderCard(order: order),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  String _statusLabel(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => 'Đã tạo đơn',
      OrderStatus.confirmed => 'Quán xác nhận',
      OrderStatus.preparing => 'Đang chuẩn bị',
      OrderStatus.readyForPickup => 'Sẵn sàng',
      OrderStatus.outForDelivery => 'Đang giao',
      OrderStatus.delivered => 'Đã giao',
      OrderStatus.cancelled => 'Đã huỷ',
    };
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(local.day)}/${pad(local.month)}/${local.year} ${pad(local.hour)}:${pad(local.minute)}';
  }

  Color _getStatusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
      case OrderStatus.pending:
        return AppColors.textSecondaryLight;
      default:
        return AppColors.info;
    }
  }

  String _formatPrice(double val) {
    final rounded = val.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < rounded.length; i++) {
      if (i > 0 && (rounded.length - i) % 3 == 0) buffer.write('.');
      buffer.write(rounded[i]);
    }
    return '${buffer.toString()}đ';
  }

  String _shortId(String value) {
    if (value.isEmpty) return 'Unknown';
    return value.length <= 8 ? value : value.substring(0, 8);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final statusColor = _getStatusColor(order.status);
    final itemsStr =
        order.items.map((i) => '${i.quantity}x ${i.name}').join(', ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.read<FoodBloc>().add(LoadOrder(orderId: order.id));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<FoodBloc>(),
                child: const OrderTrackingScreen(),
              ),
            ),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.restaurantName.isNotEmpty
                          ? order.restaurantName
                          : 'Restaurant #${_shortId(order.restaurantId)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _statusLabel(order.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _formatDate(order.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Divider(height: 20, color: AppColors.borderLight),
              Text(
                itemsStr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng cộng: ${_formatPrice(order.total)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  if (order.status != OrderStatus.delivered &&
                      order.status != OrderStatus.cancelled)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        context.read<FoodBloc>().add(
                              LoadOrder(orderId: order.id),
                            );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<FoodBloc>(),
                              child: const OrderTrackingScreen(),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Theo dõi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
