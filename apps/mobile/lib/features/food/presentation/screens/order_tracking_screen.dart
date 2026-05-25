import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/info_chip.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/skeleton_list.dart';
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

  void _retryLoad() {
    final orderId = widget.orderId;
    if (orderId != null && orderId.isNotEmpty) {
      context.read<FoodBloc>().add(LoadOrder(orderId: orderId));
      return;
    }
    context.read<FoodBloc>().add(const LoadActiveOrder());
  }

  Future<void> _confirmCancel(OrderModel order) async {
    final foodBloc = context.read<FoodBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        title: const Text('Huỷ đơn hàng?'),
        content: const Text(
          'Bạn vẫn có thể huỷ trước khi quán bàn giao cho tài xế. Nếu đã thanh toán, hệ thống sẽ hoàn tiền tự động.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Giữ đơn'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Huỷ đơn'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      foodBloc.add(CancelOrder(orderId: order.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FoodBloc, FoodState>(
      builder: (context, state) {
        if (state is FoodLoading) {
          return const Scaffold(
            backgroundColor: AppColors.backgroundLight,
            body: _OrderTrackingLoadingView(),
          );
        }

        if (state is FoodError) {
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              title: const Text(
                'Theo dõi đơn hàng',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
            body: Center(
              child: ErrorView(
                title: 'Không thể tải đơn hàng',
                message: state.message,
                retryLabel: 'Thử lại',
                onRetry: _retryLoad,
              ),
            ),
          );
        }

        if (state is! OrderTracking) {
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              title: const Text(
                'Theo dõi đơn hàng',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
            body: Center(
              child: EmptyState(
                icon: Icons.receipt_long_rounded,
                title: 'Chưa có đơn đang theo dõi',
                subtitle: 'Đơn đang giao sẽ xuất hiện tại đây khi sẵn sàng.',
                actionLabel: 'Quay lại',
                onAction: () => Navigator.pop(context),
              ),
            ),
          );
        }

        final order = state.order;
        final isCancelled = order.status == OrderStatus.cancelled;
        final isDelivered = order.status == OrderStatus.delivered;
        final canCancel = !isCancelled &&
            !isDelivered &&
            order.status != OrderStatus.outForDelivery;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: const Text(
              'Theo dõi đơn hàng',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            elevation: 0,
            scrolledUnderElevation: 0,
            actions: [
              if (canCancel)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    onPressed: () => _confirmCancel(order),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.error,
                      size: 18,
                    ),
                    label: const Text(
                      'Huỷ đơn',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusHero(order: order),
                const SizedBox(height: AppSpacing.lg),
                if (isCancelled)
                  const _CancelledBanner()
                else
                  _OrderTimeline(status: order.status),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(
                  title: 'Chi tiết đơn hàng',
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: AppSpacing.sm),
                _OrderDetailsCard(order: order),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(
                  title: 'Thanh toán',
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: AppSpacing.sm),
                _PriceSummaryCard(order: order),
                if (isDelivered || isCancelled) ...[
                  const SizedBox(height: AppSpacing.xl),
                  GradientButton(
                    label: isDelivered ? 'Xong' : 'Đóng',
                    icon: isDelivered
                        ? Icons.check_circle_rounded
                        : Icons.arrow_back_rounded,
                    height: 56,
                    borderRadius: AppRadii.lg,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusHero extends StatelessWidget {
  const _StatusHero({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final accent = _statusColor(order.status);
    final gradient = _statusGradient(order.status);

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  _statusIcon(order.status),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _statusTitle(order.status),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _statusSubtitle(order),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondaryLight,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              InfoChip(
                label: _statusChipLabel(order.status),
                icon: _statusIcon(order.status),
                variant: _statusVariant(order.status),
              ),
              InfoChip(
                label: '#${order.id.substring(0, 8).toUpperCase()}',
                icon: Icons.tag_rounded,
                variant: InfoChipVariant.defaults,
              ),
              InfoChip(
                label: order.restaurantName,
                icon: Icons.storefront_rounded,
                variant: InfoChipVariant.brand,
              ),
              if (order.estimatedMinutes != null &&
                  order.status != OrderStatus.cancelled &&
                  order.status != OrderStatus.delivered)
                InfoChip(
                  label: '${order.estimatedMinutes} phút nữa',
                  icon: Icons.schedule_rounded,
                  variant: InfoChipVariant.warning,
                  trailingDot: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  const _OrderTimeline({required this.status});

  final OrderStatus status;

  static const _steps = [
    _TimelineStepData(
      status: OrderStatus.pending,
      icon: Icons.receipt_long_rounded,
      title: 'Đã tạo đơn',
    ),
    _TimelineStepData(
      status: OrderStatus.confirmed,
      icon: Icons.check_circle_rounded,
      title: 'Quán xác nhận',
    ),
    _TimelineStepData(
      status: OrderStatus.preparing,
      icon: Icons.restaurant_rounded,
      title: 'Đang chuẩn bị',
    ),
    _TimelineStepData(
      status: OrderStatus.readyForPickup,
      icon: Icons.inventory_2_rounded,
      title: 'Sẵn sàng bàn giao',
    ),
    _TimelineStepData(
      status: OrderStatus.outForDelivery,
      icon: Icons.delivery_dining_rounded,
      title: 'Tài xế đang giao',
    ),
    _TimelineStepData(
      status: OrderStatus.delivered,
      icon: Icons.home_rounded,
      title: 'Đã giao thành công',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _steps.indexWhere((step) => step.status == status);
    final activeIndex = currentIndex < 0 ? 0 : currentIndex;
    final accent = _statusColor(status);

    return GlassCard(
      child: Column(
        children: [
          for (int i = 0; i < _steps.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TimelineNode(
                  icon: _steps[i].icon,
                  done: i < activeIndex,
                  current: i == activeIndex,
                  accent: accent,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _steps[i].title,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: i == activeIndex
                                    ? FontWeight.w800
                                    : i < activeIndex
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                color: i <= activeIndex
                                    ? AppColors.textPrimaryLight
                                    : AppColors.textSecondaryLight,
                              ),
                        ),
                        const SizedBox(height: 4),
                        if (i == activeIndex)
                          InfoChip(
                            label: status == OrderStatus.delivered
                                ? 'Hoàn tất'
                                : 'Đang diễn ra',
                            icon: status == OrderStatus.delivered
                                ? Icons.check_rounded
                                : Icons.bolt_rounded,
                            variant: status == OrderStatus.delivered
                                ? InfoChipVariant.success
                                : InfoChipVariant.brand,
                            dense: true,
                          )
                        else if (i < activeIndex)
                          const InfoChip(
                            label: 'Đã xong',
                            icon: Icons.check_rounded,
                            variant: InfoChipVariant.success,
                            dense: true,
                          ),
                      ],
                    ),
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
                  height: 24,
                  color: i < activeIndex
                      ? accent
                      : AppColors.borderLight.withValues(alpha: 0.7),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({
    required this.icon,
    required this.done,
    required this.current,
    required this.accent,
  });

  final IconData icon;
  final bool done;
  final bool current;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.normal,
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: (done || current) ? AppGradients.primary : null,
        color: (done || current) ? null : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: done || current ? Colors.transparent : AppColors.borderLight,
        ),
        boxShadow: current
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.26),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Icon(
        icon,
        size: 20,
        color: done || current ? Colors.white : AppColors.textSecondaryLight,
      ),
    );
  }
}

class _CancelledBanner extends StatelessWidget {
  const _CancelledBanner();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      tint: const Color(0xFFFFF7F7),
      borderColor: const Color(0xFFF5C2C7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_rounded,
              color: AppColors.error,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Đơn hàng đã được huỷ. Nếu đã thanh toán, hệ thống sẽ hoàn tiền trong thời gian sớm nhất theo phương thức thanh toán của bạn.',
              style: TextStyle(
                color: Color(0xFF991B1B),
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetailsCard extends StatelessWidget {
  const _OrderDetailsCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  order.restaurantName,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoChip(
                    label: '${item.quantity}x',
                    variant: InfoChipVariant.brand,
                    dense: true,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatPrice(item.subtotal, order.currency),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          Divider(
            color: AppColors.borderLight.withValues(alpha: 0.7),
            height: 18,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 18,
                color: AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                        height: 1.4,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 18,
                color: AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 8),
              Text(
                'Đặt lúc ${_formatTime(order.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceSummaryCard extends StatelessWidget {
  const _PriceSummaryCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: InfoChip(
              label: 'Tổng thanh toán',
              icon: Icons.account_balance_wallet_rounded,
              variant: InfoChipVariant.success,
              dense: true,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            label: 'Tạm tính',
            value: _formatPrice(order.subtotal, order.currency),
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Phí giao hàng',
            value: _formatPrice(order.deliveryFee, order.currency),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              height: 1,
              color: AppColors.borderLight.withValues(alpha: 0.7),
            ),
          ),
          _SummaryRow(
            label: 'Tổng cộng',
            value: _formatPrice(order.total, order.currency),
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

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

class _OrderTrackingLoadingView extends StatelessWidget {
  const _OrderTrackingLoadingView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: const [
          SizedBox(
            height: 180,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
            ),
          ),
          SizedBox(height: 16),
          SkeletonList(itemCount: 4, itemHeight: 72, spacing: 12),
        ],
      ),
    );
  }
}

class _TimelineStepData {
  const _TimelineStepData({
    required this.status,
    required this.icon,
    required this.title,
  });

  final OrderStatus status;
  final IconData icon;
  final String title;
}

String _statusTitle(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 'Đã tạo đơn';
    case OrderStatus.confirmed:
      return 'Quán đã xác nhận';
    case OrderStatus.preparing:
      return 'Đang chuẩn bị món';
    case OrderStatus.readyForPickup:
      return 'Sẵn sàng bàn giao';
    case OrderStatus.outForDelivery:
      return 'Tài xế đang giao';
    case OrderStatus.delivered:
      return 'Đã giao thành công';
    case OrderStatus.cancelled:
      return 'Đơn hàng đã huỷ';
  }
}

String _statusSubtitle(OrderModel order) {
  switch (order.status) {
    case OrderStatus.pending:
      return 'Đơn của bạn đang chờ quán xác nhận.';
    case OrderStatus.confirmed:
      return 'Quán đã nhận đơn và sẽ bắt đầu chuẩn bị ngay.';
    case OrderStatus.preparing:
      return 'Món đang được hoàn thiện để bàn giao cho tài xế.';
    case OrderStatus.readyForPickup:
      return 'Đơn đã sẵn sàng và đang chờ tài xế nhận.';
    case OrderStatus.outForDelivery:
      return order.estimatedMinutes != null
          ? 'Dự kiến đến trong ${order.estimatedMinutes} phút.'
          : 'Tài xế đang trên đường giao đơn đến bạn.';
    case OrderStatus.delivered:
      return 'Đơn hàng đã được giao tới địa chỉ của bạn.';
    case OrderStatus.cancelled:
      return 'Nếu đã thanh toán, hệ thống sẽ xử lý hoàn tiền tự động.';
  }
}

String _statusChipLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 'Chờ xác nhận';
    case OrderStatus.confirmed:
      return 'Đã xác nhận';
    case OrderStatus.preparing:
      return 'Đang chuẩn bị';
    case OrderStatus.readyForPickup:
      return 'Sẵn sàng giao';
    case OrderStatus.outForDelivery:
      return 'Đang giao';
    case OrderStatus.delivered:
      return 'Hoàn tất';
    case OrderStatus.cancelled:
      return 'Đã huỷ';
  }
}

InfoChipVariant _statusVariant(OrderStatus status) {
  switch (status) {
    case OrderStatus.delivered:
      return InfoChipVariant.success;
    case OrderStatus.cancelled:
      return InfoChipVariant.error;
    case OrderStatus.pending:
    case OrderStatus.preparing:
    case OrderStatus.readyForPickup:
      return InfoChipVariant.warning;
    case OrderStatus.confirmed:
    case OrderStatus.outForDelivery:
      return InfoChipVariant.brand;
  }
}

Color _statusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.delivered:
      return AppColors.primary;
    case OrderStatus.cancelled:
      return AppColors.error;
    case OrderStatus.pending:
    case OrderStatus.preparing:
    case OrderStatus.readyForPickup:
      return AppColors.warning;
    case OrderStatus.confirmed:
    case OrderStatus.outForDelivery:
      return AppColors.info;
  }
}

LinearGradient _statusGradient(OrderStatus status) {
  switch (status) {
    case OrderStatus.delivered:
      return AppGradients.primary;
    case OrderStatus.cancelled:
      return const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFFB7185)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case OrderStatus.pending:
    case OrderStatus.preparing:
    case OrderStatus.readyForPickup:
      return AppGradients.sunset;
    case OrderStatus.confirmed:
    case OrderStatus.outForDelivery:
      return AppGradients.walletHero;
  }
}

IconData _statusIcon(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return Icons.receipt_long_rounded;
    case OrderStatus.confirmed:
      return Icons.check_circle_rounded;
    case OrderStatus.preparing:
      return Icons.restaurant_rounded;
    case OrderStatus.readyForPickup:
      return Icons.inventory_2_rounded;
    case OrderStatus.outForDelivery:
      return Icons.delivery_dining_rounded;
    case OrderStatus.delivered:
      return Icons.home_rounded;
    case OrderStatus.cancelled:
      return Icons.cancel_rounded;
  }
}

String _formatPrice(double price, String currency) {
  if (currency.toUpperCase() == 'VND') {
    if (price <= 0) return '0đ';
    final thousand = (price / 1000).toStringAsFixed(0);
    return '$thousand.000đ';
  }
  return '${price.toStringAsFixed(0)} $currency';
}

String _formatTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
