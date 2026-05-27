import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/auth_storage.dart';
import '../../../../shared/utils/error_message.dart';
import '../../data/models/ride_models.dart';
import '../../data/repositories/ride_repository.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  late Future<List<Ride>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Ride>> _load() async {
    final riderId = await sl<AuthStorage>().getUserId();
    if (riderId == null || riderId.isEmpty) return [];
    return sl<RideRepository>().getMyRides(riderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Lịch sử chuyến đi',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.backgroundLight,
      ),
      body: FutureBuilder<List<Ride>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _MessageState(
              icon: Icons.error_outline,
              title: 'Không tải được lịch sử chuyến đi',
              message: mapErrorToMessage(snapshot.error),
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final rides = snapshot.data ?? [];
          if (rides.isEmpty) {
            return const _MessageState(
              icon: Icons.route_outlined,
              title: 'Chưa có chuyến đi',
              message:
                  'Các chuyến đã hoàn thành hoặc đã huỷ sẽ xuất hiện tại đây.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => setState(() => _future = _load()),
            color: AppColors.primary,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: rides.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _RideTile(ride: rides[index]),
            ),
          );
        },
      ),
    );
  }
}

class _RideTile extends StatelessWidget {
  const _RideTile({required this.ride});
  final Ride ride;

  String _formatVnd(int value) {
    if (value <= 0) return '--';
    final raw = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) buffer.write('.');
      buffer.write(raw[i]);
    }
    return '${buffer.toString()}đ';
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(local.day)}/${pad(local.month)} • ${pad(local.hour)}:${pad(local.minute)}';
  }

  String _statusLabel(RideStatus status) {
    return switch (status) {
      RideStatus.requested => 'Đang tìm tài xế',
      RideStatus.matched => 'Đã có tài xế',
      RideStatus.pickup => 'Tài xế đang đến',
      RideStatus.inProgress => 'Đang di chuyển',
      RideStatus.completed => 'Hoàn tất',
      RideStatus.cancelled => 'Đã huỷ',
    };
  }

  Color _statusColor(RideStatus status) {
    return switch (status) {
      RideStatus.completed => AppColors.success,
      RideStatus.cancelled => AppColors.error,
      RideStatus.requested => AppColors.warning,
      _ => AppColors.primary,
    };
  }

  String _vehicleLabel(String type) {
    return switch (type) {
      'BIKE' => 'CrabBike',
      'CAR_4' => 'CrabCar',
      'CAR_7' => 'CrabCar 7',
      'PREMIUM' => 'CrabPremium',
      _ => 'CrabRide',
    };
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(ride.status);
    final pickup = ride.pickup.address ?? 'Điểm đón';
    final dropoff = ride.dropoff.address ?? 'Điểm đến';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push('/ride/${ride.id}'),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.local_taxi_rounded,
                      color: statusColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _vehicleLabel(ride.vehicleType),
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(ride.createdAt),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  _StatusPill(
                      label: _statusLabel(ride.status), color: statusColor),
                ],
              ),
              const SizedBox(height: 14),
              _RouteLine(label: 'Đón', value: pickup, color: AppColors.success),
              const SizedBox(height: 8),
              _RouteLine(label: 'Đến', value: dropoff, color: AppColors.error),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _MetaText(
                        label: 'Quãng đường',
                        value: '${ride.distanceKm.toStringAsFixed(1)} km',
                      ),
                    ),
                    Expanded(
                      child: _MetaText(
                        label: 'Thời gian',
                        value: '${ride.durationMin} phút',
                      ),
                    ),
                    Expanded(
                      child: _MetaText(
                        label: 'Giá cước',
                        value: _formatVnd(ride.fare),
                        highlight: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteLine extends StatelessWidget {
  const _RouteLine({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 36,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondaryLight,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color:
                    highlight ? AppColors.primary : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
            ],
          ],
        ),
      ),
    );
  }
}
