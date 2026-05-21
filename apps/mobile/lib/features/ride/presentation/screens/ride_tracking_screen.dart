import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/error_message.dart';
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
    try {
      final repo = sl<RideRepository>();
      final ride = await repo.getRide(widget.rideId);
      if (mounted) {
        setState(() {
          _ride = ride;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mapErrorToMessage(e))),
        );
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

  driver_models.DriverModel _placeholderDriver() {
    return const driver_models.DriverModel(
      id: 'placeholder',
      name: 'Tai xe Crab',
      phone: '',
      rating: 4.9,
      totalRides: 1280,
      vehicle: driver_models.VehicleModel(
        plate: '51A-123.45',
        model: 'Toyota Vios',
        color: 'Trang',
        type: 'CAR_4',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final r = _ride;
    if (r == null) {
      return const Scaffold(body: Center(child: Text('Ride not found')));
    }

    final etaMin = r.durationMin;

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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _CircularBackButton(
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatusChip(
                      label: 'Tai xe den trong $etaMin phut',
                      pulseCtrl: _pulseCtrl,
                    ),
                  ),
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.35,
            maxChildSize: 0.6,
            snap: true,
            snapSizes: const [0.35, 0.6],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 24,
                      offset: Offset(0, -8),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DriverInfoCard(
                        driver: _placeholderDriver(),
                        etaMinutes: etaMin,
                        onCall: _call,
                        onChat: _openChat,
                        onCancel: _cancel,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _TripSummary(ride: r),
                    ),
                    const SizedBox(height: 24),
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
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
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
  final String label;
  final AnimationController pulseCtrl;

  const _StatusChip({required this.label, required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
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
                            color:
                                AppColors.primary.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
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
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripSummary extends StatelessWidget {
  final Ride ride;
  const _TripSummary({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          _RouteRow(
            icon: Icons.my_location_rounded,
            iconColor: AppColors.success,
            label: 'Diem don',
            value: ride.pickup.address ?? '-',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: AppColors.borderLight),
          ),
          _RouteRow(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.error,
            label: 'Diem den',
            value: ride.dropoff.address ?? '-',
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${ride.distanceKm.toStringAsFixed(1)} km - ${ride.durationMin} phut',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${ride.fare} VND',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
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
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
