import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/error_message.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/skeleton_list.dart';
import '../../data/models/driver_model.dart' as driver_models;
import '../../data/models/location_model.dart';
import '../../data/models/ride_models.dart';
import '../../data/repositories/ride_repository.dart';
import '../widgets/driver_info_card.dart';
import '../widgets/tracking_map.dart';

class RideTrackingScreen extends StatefulWidget {
  final String rideId;
  const RideTrackingScreen({super.key, required this.rideId});

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen>
    with SingleTickerProviderStateMixin {
  Ride? _ride;
  bool _loading = true;
  String? _errorMessage;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
    _load();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
    }

    try {
      final repo = sl<RideRepository>();
      final ride = await repo.getRide(widget.rideId);
      if (mounted) {
        setState(() {
          _ride = ride;
          _loading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _ride = null;
          _loading = false;
          _errorMessage = mapErrorToMessage(e);
        });
      }
    }
  }

  Future<void> _cancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Huy chuyen di?'),
        content: const Text('Ban chac chan muon huy chuyen di nay?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Khong'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Co, huy'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      final repo = sl<RideRepository>();
      await repo.cancelRide(widget.rideId, reason: 'User cancelled');
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(mapErrorToMessage(e))));
      }
    }
  }

  void _openChat() {
    final r = _ride;
    if (r == null) return;
    context.push('/chat/ride_${r.id}');
  }

  void _call() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dang ket noi cuoc goi...')),
    );
  }

  driver_models.DriverModel _driverSummaryForRide(Ride ride) {
    final assignedDriverId = ride.driverId?.trim();
    final hasAssignedDriver =
        assignedDriverId != null && assignedDriverId.isNotEmpty;

    return driver_models.DriverModel(
      id: hasAssignedDriver ? assignedDriverId : 'driver-assignment-pending',
      name: hasAssignedDriver ? 'Tài xế đã nhận chuyến' : 'Đang tìm tài xế',
      phone: '',
      rating: 0,
      totalRides: 0,
      vehicle: driver_models.VehicleModel(
        plate: hasAssignedDriver ? 'Hồ sơ tài xế' : 'Đang ghép tài xế',
        model: hasAssignedDriver
            ? 'ID ${_shortDriverId(assignedDriverId)}'
            : ride.vehicleType,
        color: 'Crab',
        type: ride.vehicleType,
      ),
    );
  }

  String _shortDriverId(String driverId) {
    return driverId.length <= 8 ? driverId : '${driverId.substring(0, 8)}...';
  }

  String _statusTitle(RideStatus status) {
    switch (status) {
      case RideStatus.requested:
        return 'Đang tìm tài xế';
      case RideStatus.matched:
        return 'Tài xế đã nhận chuyến';
      case RideStatus.pickup:
        return 'Tài xế đang đến điểm đón';
      case RideStatus.inProgress:
        return 'Bạn đang trên hành trình';
      case RideStatus.completed:
        return 'Chuyến đi đã hoàn tất';
      case RideStatus.cancelled:
        return 'Chuyến đi đã huỷ';
    }
  }

  String _statusSubtitle(Ride ride) {
    switch (ride.status) {
      case RideStatus.requested:
      case RideStatus.matched:
      case RideStatus.pickup:
        return 'Dự kiến đón trong khoảng ${ride.durationMin} phút.';
      case RideStatus.inProgress:
        return 'Lộ trình còn khoảng ${ride.distanceKm.toStringAsFixed(1)} km.';
      case RideStatus.completed:
        return 'Cảm ơn bạn đã lựa chọn Crab cho chuyến đi này.';
      case RideStatus.cancelled:
        return 'Bạn có thể đặt lại chuyến xe bất cứ lúc nào.';
    }
  }

  Color _statusColor(RideStatus status) {
    switch (status) {
      case RideStatus.requested:
        return AppColors.warning;
      case RideStatus.matched:
      case RideStatus.pickup:
        return AppColors.primary;
      case RideStatus.inProgress:
        return AppColors.info;
      case RideStatus.completed:
        return AppColors.success;
      case RideStatus.cancelled:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: _TrackingLoadingView());
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: _TrackingStateScaffold(
          child: Center(
            child: ErrorView(
              title: 'Không thể tải hành trình',
              message: _errorMessage,
              retryLabel: 'Thử lại',
              onRetry: _load,
            ),
          ),
        ),
      );
    }

    final r = _ride;
    if (r == null) {
      return const Scaffold(
        body: _TrackingStateScaffold(
          child: Center(
            child: EmptyState(
              icon: Icons.route_rounded,
              title: 'Không tìm thấy chuyến đi',
              subtitle:
                  'Chuyến xe này có thể đã kết thúc hoặc không còn khả dụng.',
              compact: true,
            ),
          ),
        ),
      );
    }

    final etaMin = r.durationMin;
    final statusColor = _statusColor(r.status);
    final hasAssignedDriver = r.driverId?.trim().isNotEmpty ?? false;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: TrackingMap(
              pickup: LocationModel(
                latitude: r.pickup.latitude,
                longitude: r.pickup.longitude,
                address: r.pickup.address,
              ),
              dropoff: LocationModel(
                latitude: r.dropoff.latitude,
                longitude: r.dropoff.longitude,
                address: r.dropoff.address,
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.14),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.10),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CircularBackButton(
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatusChip(
                      title: _statusTitle(r.status),
                      subtitle: _statusSubtitle(r),
                      color: statusColor,
                      pulseCtrl: _pulseCtrl,
                    ),
                  ),
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.38,
            minChildSize: 0.38,
            maxChildSize: 0.68,
            snap: true,
            snapSizes: const [0.38, 0.68],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 28,
                      offset: Offset(0, -10),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Thông tin chuyến đi',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Theo dõi tài xế và xem nhanh chi tiết hành trình của bạn.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DriverInfoCard(
                      driver: _driverSummaryForRide(r),
                      etaMinutes:
                          r.status == RideStatus.inProgress ? null : etaMin,
                      statusLabel: _statusTitle(r.status),
                      onCall: hasAssignedDriver ? _call : null,
                      onChat: hasAssignedDriver ? _openChat : null,
                      onCancel: _cancel,
                    ),
                    const SizedBox(height: 16),
                    _TripMetaRow(ride: r, statusColor: statusColor),
                    const SizedBox(height: 16),
                    _TripSummary(ride: r),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CircularBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _CircularBackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IconButton(
        iconSize: 20,
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: onPressed,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final AnimationController pulseCtrl;

  const _StatusChip({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.pulseCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(22),
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: pulseCtrl,
              builder: (_, __) {
                final t = pulseCtrl.value;
                return SizedBox(
                  width: 18,
                  height: 18,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: (1 - t).clamp(0.0, 1.0),
                        child: Container(
                          width: 8 + 10 * t,
                          height: 8 + 10 * t,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackingStateScaffold extends StatelessWidget {
  final Widget child;

  const _TrackingStateScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  _CircularBackButton(
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _TrackingLoadingView extends StatelessWidget {
  const _TrackingLoadingView();

  @override
  Widget build(BuildContext context) {
    return _TrackingStateScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Color(0x1A00B14F),
                  child: Icon(
                    Icons.route_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Đang tải hành trình',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Crab đang đồng bộ vị trí tài xế và lộ trình mới nhất cho bạn.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SkeletonList(
            itemCount: 2,
            itemHeight: 92,
            spacing: 12,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.borderLight.withValues(alpha: 0.8),
              ),
            ),
            child: const SkeletonList(
              itemCount: 3,
              itemHeight: 44,
              spacing: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _TripMetaRow extends StatelessWidget {
  final Ride ride;
  final Color statusColor;

  const _TripMetaRow({required this.ride, required this.statusColor});

  String _shortStatus(RideStatus status) {
    switch (status) {
      case RideStatus.requested:
        return 'Đang tìm';
      case RideStatus.matched:
        return 'Đã ghép';
      case RideStatus.pickup:
        return 'Đón khách';
      case RideStatus.inProgress:
        return 'Đang đi';
      case RideStatus.completed:
        return 'Hoàn tất';
      case RideStatus.cancelled:
        return 'Đã huỷ';
    }
  }

  String _formatPrice(int value) {
    final rounded = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < rounded.length; i++) {
      if (i > 0 && (rounded.length - i) % 3 == 0) buffer.write('.');
      buffer.write(rounded[i]);
    }
    return '$buffer' 'đ';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetaCard(
            label: 'Trạng thái',
            value: _shortStatus(ride.status),
            accentColor: statusColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetaCard(
            label: 'Thời gian',
            value: '${ride.durationMin} phút',
            accentColor: AppColors.info,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetaCard(
            label: 'Cước phí',
            value: _formatPrice(ride.fare),
            accentColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _MetaCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _MetaCard({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _TripSummary extends StatelessWidget {
  final Ride ride;
  const _TripSummary({required this.ride});

  String _formatPrice(int value) {
    final rounded = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < rounded.length; i++) {
      if (i > 0 && (rounded.length - i) % 3 == 0) buffer.write('.');
      buffer.write(rounded[i]);
    }
    return '$buffer' 'đ';
  }

  String _vehicleLabel(String raw) {
    switch (raw) {
      case 'BIKE':
        return 'CrabBike';
      case 'CAR_4':
        return 'CrabCar';
      case 'CAR_7':
        return 'CrabCar 7';
      default:
        return raw.replaceAll('_', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideCode = ride.id.length > 8 ? ride.id.substring(0, 8) : ride.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lộ trình và thanh toán',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 14),
          _RouteRow(
            icon: Icons.my_location_rounded,
            iconColor: AppColors.success,
            label: 'Điểm đón',
            value: ride.pickup.address ?? '-',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.borderLight),
          ),
          _RouteRow(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.error,
            label: 'Điểm đến',
            value: ride.dropoff.address ?? '-',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mã chuyến #${rideCode.toUpperCase()} • ${_vehicleLabel(ride.vehicleType)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatPrice(ride.fare),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${ride.distanceKm.toStringAsFixed(1)} km • ${ride.durationMin} phút',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _RouteRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
