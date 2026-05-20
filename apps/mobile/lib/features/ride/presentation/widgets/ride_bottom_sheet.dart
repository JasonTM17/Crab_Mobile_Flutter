import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/location_model.dart';

class RideBottomSheet extends StatefulWidget {
  final LocationModel? pickup;
  final LocationModel? dropoff;
  final FareEstimate? fareEstimate;
  final VoidCallback onPickupTap;
  final VoidCallback onDropoffTap;
  final VoidCallback onBookRide;

  const RideBottomSheet({
    super.key,
    this.pickup,
    this.dropoff,
    this.fareEstimate,
    required this.onPickupTap,
    required this.onDropoffTap,
    required this.onBookRide,
  });

  @override
  State<RideBottomSheet> createState() => _RideBottomSheetState();
}

class _RideBottomSheetState extends State<RideBottomSheet>
    with SingleTickerProviderStateMixin {
  int _selectedVehicle = 1;
  late final AnimationController _pulseCtrl;

  static const _vehicles = <_VehicleOption>[
    _VehicleOption('Bike', Icons.two_wheeler),
    _VehicleOption('Car 4', Icons.directions_car),
    _VehicleOption('Car 7', Icons.airport_shuttle),
    _VehicleOption('Premium', Icons.car_rental),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canBook = widget.pickup != null && widget.dropoff != null;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _LocationTimeline(
                pickup: widget.pickup,
                dropoff: widget.dropoff,
                onPickupTap: widget.onPickupTap,
                onDropoffTap: widget.onDropoffTap,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: _AddStopChip(),
              ),
              const SizedBox(height: 16),
              _VehiclePicker(
                vehicles: _vehicles,
                selected: _selectedVehicle,
                onSelect: (i) => setState(() => _selectedVehicle = i),
              ),
              if (widget.fareEstimate != null) ...[
                const SizedBox(height: 16),
                _FareEstimatePanel(
                  fareEstimate: widget.fareEstimate!,
                  pulseCtrl: _pulseCtrl,
                ),
              ],
              const SizedBox(height: 16),
              _GradientBookButton(
                enabled: canBook,
                onPressed: canBook ? widget.onBookRide : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleOption {
  final String label;
  final IconData icon;
  const _VehicleOption(this.label, this.icon);
}

class _LocationTimeline extends StatelessWidget {
  final LocationModel? pickup;
  final LocationModel? dropoff;
  final VoidCallback onPickupTap;
  final VoidCallback onDropoffTap;

  const _LocationTimeline({
    required this.pickup,
    required this.dropoff,
    required this.onPickupTap,
    required this.onDropoffTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 22,
            child: CustomPaint(
              painter: _TimelinePainter(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                _LocationRow(
                  label: pickup?.name ?? pickup?.address ?? 'Set pickup',
                  placeholder: pickup == null,
                  onTap: onPickupTap,
                ),
                const SizedBox(height: 8),
                _LocationRow(
                  label: dropoff?.name ?? dropoff?.address ?? 'Where to?',
                  placeholder: dropoff == null,
                  onTap: onDropoffTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final greenPaint = Paint()..color = AppColors.success;
    final redPaint = Paint()..color = AppColors.error;
    final dotPaint = Paint()
      ..color = AppColors.borderLight
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5;

    final cx = size.width / 2;
    final topCy = 24.0;
    final botCy = size.height - 24.0;

    canvas.drawCircle(Offset(cx, topCy), 6, greenPaint);
    canvas.drawCircle(
      Offset(cx, topCy),
      6,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(Offset(cx, topCy), 2.5, Paint()..color = Colors.white);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 5, botCy - 5, 10, 10),
        const Radius.circular(2),
      ),
      redPaint,
    );

    double y = topCy + 12;
    while (y < botCy - 8) {
      canvas.drawLine(Offset(cx, y), Offset(cx, y + 3), dotPaint);
      y += 6;
    }
  }

  @override
  bool shouldRepaint(covariant _TimelinePainter oldDelegate) => false;
}

class _LocationRow extends StatelessWidget {
  final String label;
  final bool placeholder;
  final VoidCallback onTap;

  const _LocationRow({
    required this.label,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: placeholder
                      ? AppColors.textSecondaryLight
                      : AppColors.textPrimaryLight,
                  fontWeight:
                      placeholder ? FontWeight.normal : FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondaryLight, size: 20),
          ],
        ),
      ),
    );
  }
}

class _VehiclePicker extends StatelessWidget {
  final List<_VehicleOption> vehicles;
  final int selected;
  final ValueChanged<int> onSelect;

  const _VehiclePicker({
    required this.vehicles,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: vehicles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final v = vehicles[i];
          final isActive = i == selected;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryLight,
                        ],
                      )
                    : null,
                color: isActive ? null : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: isActive
                      ? Colors.transparent
                      : AppColors.borderLight,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.45),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    v.icon,
                    size: 16,
                    color: isActive
                        ? Colors.white
                        : AppColors.textPrimaryLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    v.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? Colors.white
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FareEstimatePanel extends StatelessWidget {
  final FareEstimate fareEstimate;
  final AnimationController pulseCtrl;

  const _FareEstimatePanel({
    required this.fareEstimate,
    required this.pulseCtrl,
  });

  String _fmt(double n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}k';
    return n.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final fare = fareEstimate;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimated fare',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_fmt(fare.minFare)}–${_fmt(fare.maxFare)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        fare.currency,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  children: [
                    AnimatedBuilder(
                      animation: pulseCtrl,
                      builder: (_, __) {
                        final t = pulseCtrl.value;
                        return Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withOpacity(0.5 + 0.5 * (1 - t)),
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${fare.estimatedMinutes} min',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${fare.distanceKm.toStringAsFixed(1)} km',
                style: const TextStyle(
                  fontSize: 12,
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

class _GradientBookButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onPressed;

  const _GradientBookButton({required this.enabled, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Book ride',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 6),
              Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddStopChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(99),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.add, size: 14, color: AppColors.primary),
              SizedBox(width: 4),
              Text(
                'Add stop',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
