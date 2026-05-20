import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/driver_model.dart';

class DriverInfoCard extends StatefulWidget {
  final DriverModel driver;
  final int? etaMinutes;
  final String? statusLabel;

  const DriverInfoCard({
    super.key,
    required this.driver,
    this.etaMinutes,
    this.statusLabel,
  });

  @override
  State<DriverInfoCard> createState() => _DriverInfoCardState();
}

class _DriverInfoCardState extends State<DriverInfoCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
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
    final driver = widget.driver;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.statusLabel != null) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PulsingDot(controller: _pulseCtrl, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    widget.statusLabel!,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    backgroundImage: driver.avatar != null
                        ? NetworkImage(driver.avatar!)
                        : null,
                    child: driver.avatar == null
                        ? Text(
                            driver.name.isNotEmpty
                                ? driver.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: _PulsingDot(
                      controller: _pulseCtrl,
                      color: AppColors.success,
                      size: 12,
                      ringWidth: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.amber, size: 16),
                        const SizedBox(width: 2),
                        Text(
                          driver.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurfaceVariant,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${driver.totalRides} trips',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 56,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _vehicleIcon(driver.vehicle.type),
                  size: 22,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.directions_car_filled_outlined,
                    size: 18, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${driver.vehicle.color} ${driver.vehicle.model}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.borderLight),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    driver.vehicle.plate,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.etaMinutes != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Arriving in ${widget.etaMinutes} min',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _vehicleIcon(String type) {
    final t = type.toUpperCase();
    if (t.contains('BIKE') || t.contains('MOTOR')) return Icons.two_wheeler;
    if (t.contains('PREMIUM')) return Icons.car_rental;
    if (t.contains('7')) return Icons.airport_shuttle;
    return Icons.directions_car;
  }
}

class _PulsingDot extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final double size;
  final double ringWidth;

  const _PulsingDot({
    required this.controller,
    required this.color,
    this.size = 8,
    this.ringWidth = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        return SizedBox(
          width: size + 14,
          height: size + 14,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: (1 - t).clamp(0.0, 1.0),
                child: Container(
                  width: size + 14 * t,
                  height: size + 14 * t,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.35),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: ringWidth > 0
                      ? Border.all(color: Colors.white, width: ringWidth)
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
