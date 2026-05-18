import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../bloc/driver_state.dart';

class IncomingRideCard extends StatelessWidget {
  final RideRequest rideRequest;
  final int countdown;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const IncomingRideCard({
    super.key,
    required this.rideRequest,
    required this.countdown,
    required this.onAccept,
    required this.onReject,
  });

  String _formatFare(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countdownFraction = countdown / 15.0;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with countdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_active, size: 20),
                const SizedBox(width: 8),
                Text(
                  'New Ride Request',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const Spacer(),
                // Circular countdown timer
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(48, 48),
                        painter: _CountdownPainter(
                          fraction: countdownFraction,
                          color: countdown <= 5
                              ? Colors.red
                              : theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        '$countdown',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: countdown <= 5
                              ? Colors.red
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Ride details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Pickup
                _AddressRow(
                  icon: Icons.circle,
                  iconColor: Colors.green,
                  label: 'Pickup',
                  address: rideRequest.pickupAddress,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Container(
                    height: 20,
                    width: 2,
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
                // Dropoff
                _AddressRow(
                  icon: Icons.location_on,
                  iconColor: Colors.red,
                  label: 'Destination',
                  address: rideRequest.dropoffAddress,
                ),
                const SizedBox(height: 16),
                // Fare and distance
                Row(
                  children: [
                    Expanded(
                      child: _InfoChip(
                        icon: Icons.payments_outlined,
                        label:
                            '${_formatFare(rideRequest.estimatedFare)} ${rideRequest.currency}',
                        color: theme.colorScheme.primaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoChip(
                        icon: Icons.straighten,
                        label:
                            '${rideRequest.distanceKm.toStringAsFixed(1)} km',
                        color: theme.colorScheme.secondaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Accept / Reject buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Reject',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: onAccept,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String address;

  const _AddressRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                address,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _CountdownPainter extends CustomPainter {
  final double fraction;
  final Color color;

  _CountdownPainter({required this.fraction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Background circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CountdownPainter old) =>
      old.fraction != fraction || old.color != color;
}
