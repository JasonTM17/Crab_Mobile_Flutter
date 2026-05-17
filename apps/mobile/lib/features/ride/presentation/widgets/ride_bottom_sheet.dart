import 'package:flutter/material.dart';

import '../../data/models/location_model.dart';

class RideBottomSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canBook = pickup != null && dropoff != null;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Location inputs
              _LocationInput(
                icon: Icons.circle,
                iconColor: Colors.green,
                label: pickup?.name ?? pickup?.address ?? 'Set pickup location',
                placeholder: pickup == null,
                onTap: onPickupTap,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Container(
                  height: 20,
                  width: 2,
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              _LocationInput(
                icon: Icons.location_on,
                iconColor: Colors.red,
                label: dropoff?.name ?? dropoff?.address ?? 'Where to?',
                placeholder: dropoff == null,
                onTap: onDropoffTap,
              ),
              if (fareEstimate != null) ...[
                const SizedBox(height: 16),
                _FareEstimateRow(fareEstimate: fareEstimate!),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: canBook ? onBookRide : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Book Ride',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationInput extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool placeholder;
  final VoidCallback onTap;

  const _LocationInput({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: placeholder
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                  fontWeight:
                      placeholder ? FontWeight.normal : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _FareEstimateRow extends StatelessWidget {
  final FareEstimate fareEstimate;

  const _FareEstimateRow({required this.fareEstimate});

  String _formatFare(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.payments_outlined,
              color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Estimated fare: ${_formatFare(fareEstimate.minFare)} - ${_formatFare(fareEstimate.maxFare)} ${fareEstimate.currency}',
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${fareEstimate.estimatedMinutes} min',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
