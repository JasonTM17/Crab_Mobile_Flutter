import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/location_model.dart';

class RideBottomSheet extends StatefulWidget {
  final ScrollController? scrollController;
  final LocationModel? pickup;
  final LocationModel? dropoff;
  final FareEstimate? fareEstimate;
  final VoidCallback onPickupTap;
  final VoidCallback onDropoffTap;
  final VoidCallback onBookRide;
  final VoidCallback? onSwap;

  const RideBottomSheet({
    super.key,
    this.scrollController,
    this.pickup,
    this.dropoff,
    this.fareEstimate,
    required this.onPickupTap,
    required this.onDropoffTap,
    required this.onBookRide,
    this.onSwap,
  });

  @override
  State<RideBottomSheet> createState() => _RideBottomSheetState();
}

class _RideBottomSheetState extends State<RideBottomSheet> {
  int _selectedVehicle = 1;

  static const List<_VehicleOption> _vehicles = [
    _VehicleOption(
      type: 'BIKE',
      label: 'GrabBike',
      etaText: '3 phut',
      icon: Icons.two_wheeler_rounded,
      tint: Color(0xFFFFE6CC),
      iconColor: Color(0xFFFF8A00),
      multiplier: 0.55,
    ),
    _VehicleOption(
      type: 'CAR_4',
      label: 'GrabCar',
      etaText: '5 phut',
      icon: Icons.directions_car_rounded,
      tint: Color(0xFFD9F5E5),
      iconColor: AppColors.primary,
      multiplier: 1.0,
    ),
    _VehicleOption(
      type: 'CAR_7',
      label: 'GrabCar 7',
      etaText: '7 phut',
      icon: Icons.airport_shuttle_rounded,
      tint: Color(0xFFE0EAFE),
      iconColor: Color(0xFF1A73E8),
      multiplier: 1.35,
    ),
  ];

  String _formatPrice(double v) {
    final n = v.round();
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  double _basePrice() {
    final fare = widget.fareEstimate;
    if (fare == null) return 0;
    return (fare.minFare + fare.maxFare) / 2;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canBook = widget.pickup != null && widget.dropoff != null;
    final base = _basePrice();
    final selectedPrice = base * _vehicles[_selectedVehicle].multiplier;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: ListView(
        controller: widget.scrollController,
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
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _LocationBlock(
              pickupAddress: widget.pickup?.name ??
                  widget.pickup?.address ??
                  'Chon diem don',
              dropoffAddress: widget.dropoff?.name ??
                  widget.dropoff?.address ??
                  'Chon diem den',
              hasPickup: widget.pickup != null,
              hasDropoff: widget.dropoff != null,
              onPickupTap: widget.onPickupTap,
              onDropoffTap: widget.onDropoffTap,
              onSwap: widget.onSwap,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Chon loai xe',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (var i = 0; i < _vehicles.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _VehicleCard(
                      option: _vehicles[i],
                      selected: i == _selectedVehicle,
                      priceText: base > 0
                          ? '${_formatPrice(base * _vehicles[i].multiplier)}d'
                          : '--',
                      onTap: () => setState(() => _selectedVehicle = i),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: _GradientBookButton(
              enabled: canBook,
              priceText: base > 0 ? _formatPrice(selectedPrice) : null,
              onPressed: canBook ? widget.onBookRide : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleOption {
  final String type;
  final String label;
  final String etaText;
  final IconData icon;
  final Color tint;
  final Color iconColor;
  final double multiplier;

  const _VehicleOption({
    required this.type,
    required this.label,
    required this.etaText,
    required this.icon,
    required this.tint,
    required this.iconColor,
    required this.multiplier,
  });
}

class _LocationBlock extends StatelessWidget {
  final String pickupAddress;
  final String dropoffAddress;
  final bool hasPickup;
  final bool hasDropoff;
  final VoidCallback onPickupTap;
  final VoidCallback onDropoffTap;
  final VoidCallback? onSwap;

  const _LocationBlock({
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.hasPickup,
    required this.hasDropoff,
    required this.onPickupTap,
    required this.onDropoffTap,
    this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: CustomPaint(painter: _ConnectorPainter()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                _LocationRow(
                  label: 'Diem don',
                  address: pickupAddress,
                  placeholder: !hasPickup,
                  onTap: onPickupTap,
                ),
                const SizedBox(height: 14),
                _LocationRow(
                  label: 'Diem den',
                  address: dropoffAddress,
                  placeholder: !hasDropoff,
                  onTap: onDropoffTap,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onSwap,
            tooltip: 'Doi cho',
            iconSize: 20,
            icon: const Icon(Icons.swap_vert_rounded,
                color: AppColors.textSecondaryLight),
          ),
        ],
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    const topCy = 12.0;
    final botCy = size.height - 12.0;

    final greenPaint = Paint()..color = AppColors.success;
    canvas.drawCircle(Offset(cx, topCy), 5, greenPaint);
    canvas.drawCircle(
      Offset(cx, topCy),
      5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final redPaint = Paint()..color = AppColors.error;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 5, botCy - 5, 10, 10),
        const Radius.circular(2),
      ),
      redPaint,
    );

    final dashPaint = Paint()
      ..color = AppColors.borderLight
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    var y = topCy + 10;
    while (y < botCy - 8) {
      canvas.drawLine(Offset(cx, y), Offset(cx, y + 4), dashPaint);
      y += 7;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LocationRow extends StatelessWidget {
  final String label;
  final String address;
  final bool placeholder;
  final VoidCallback onTap;

  const _LocationRow({
    required this.label,
    required this.address,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: placeholder ? FontWeight.w500 : FontWeight.w600,
                color: placeholder
                    ? AppColors.textSecondaryLight
                    : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final _VehicleOption option;
  final bool selected;
  final String priceText;
  final VoidCallback onTap;

  const _VehicleCard({
    required this.option,
    required this.selected,
    required this.priceText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.06)
          : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  selected ? AppColors.primary : AppColors.borderLight,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: option.tint,
                  shape: BoxShape.circle,
                ),
                child: Icon(option.icon, color: option.iconColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Den sau ${option.etaText}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                priceText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientBookButton extends StatelessWidget {
  final bool enabled;
  final String? priceText;
  final VoidCallback? onPressed;

  const _GradientBookButton({
    required this.enabled,
    this.priceText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final label = priceText != null
        ? 'Dat xe ngay - ${priceText}d'
        : 'Dat xe ngay';
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
