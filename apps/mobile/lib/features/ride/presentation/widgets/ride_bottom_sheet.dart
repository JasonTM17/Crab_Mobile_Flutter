import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/gradient_button.dart';
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
  final bool isLoading;
  final String? errorMessage;

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
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  State<RideBottomSheet> createState() => _RideBottomSheetState();
}

class _RideBottomSheetState extends State<RideBottomSheet> {
  int _selectedVehicle = 1;

  static const List<_VehicleOption> _vehicles = [
    _VehicleOption(
      type: 'BIKE',
      label: 'CrabBike',
      subtitle: 'Nhanh gọn cho quãng ngắn',
      etaText: '3 phút',
      icon: Icons.two_wheeler_rounded,
      tint: Color(0xFFFFE8D2),
      iconColor: Color(0xFFFF8A00),
      multiplier: 0.55,
    ),
    _VehicleOption(
      type: 'CAR_4',
      label: 'CrabCar',
      subtitle: 'Thoải mái cho 1-4 khách',
      etaText: '5 phút',
      icon: Icons.directions_car_filled_rounded,
      tint: Color(0xFFD9F5E5),
      iconColor: AppColors.primary,
      multiplier: 1.0,
    ),
    _VehicleOption(
      type: 'CAR_7',
      label: 'CrabCar 7',
      subtitle: 'Rộng rãi cho nhóm nhỏ',
      etaText: '7 phút',
      icon: Icons.airport_shuttle_rounded,
      tint: Color(0xFFE1EAFF),
      iconColor: AppColors.info,
      multiplier: 1.35,
    ),
  ];

  String _formatPrice(double value) {
    final rounded = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < rounded.length; i++) {
      if (i > 0 && (rounded.length - i) % 3 == 0) buffer.write('.');
      buffer.write(rounded[i]);
    }
    return buffer.toString();
  }

  double _basePrice() {
    final fare = widget.fareEstimate;
    if (fare == null) return 0;
    return (fare.minFare + fare.maxFare) / 2;
  }

  @override
  Widget build(BuildContext context) {
    final canBook = widget.pickup != null && widget.dropoff != null;
    final fareEstimate = widget.fareEstimate;
    final base = _basePrice();
    final selectedPrice = base * _vehicles[_selectedVehicle].multiplier;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 28,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
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
            'Đặt chuyến',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            canBook
                ? 'Chọn loại xe phù hợp và xác nhận chuyến đi của bạn.'
                : 'Thêm điểm đón và điểm đến để xem giá cước ước tính.',
            style: const TextStyle(
              fontSize: 14,
              height: 1.35,
              color: AppColors.textSecondaryLight,
            ),
          ),
          if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty) ...[
            const SizedBox(height: 14),
            _MessageCard(
              icon: Icons.error_outline_rounded,
              color: AppColors.error,
              message: widget.errorMessage!,
            ),
          ],
          if (widget.isLoading) ...[
            const SizedBox(height: 14),
            const _MessageCard(
              icon: Icons.tune_rounded,
              color: AppColors.primary,
              message: 'Đang cập nhật giá cước và tìm lựa chọn phù hợp...',
              loading: true,
            ),
          ],
          const SizedBox(height: 16),
          _LocationBlock(
            pickupAddress: widget.pickup?.name ??
                widget.pickup?.address ??
                'Chọn điểm đón',
            dropoffAddress: widget.dropoff?.name ??
                widget.dropoff?.address ??
                'Chọn điểm đến',
            hasPickup: widget.pickup != null,
            hasDropoff: widget.dropoff != null,
            onPickupTap: widget.onPickupTap,
            onDropoffTap: widget.onDropoffTap,
            onSwap: widget.onSwap,
          ),
          if (fareEstimate != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _FareMeta(
                    label: 'Quãng đường',
                    value: '${fareEstimate.distanceKm.toStringAsFixed(1)} km',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FareMeta(
                    label: 'Thời gian',
                    value: '${fareEstimate.estimatedMinutes} phút',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FareMeta(
                    label: 'Giá dự kiến',
                    value: '${_formatPrice(base)}đ',
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Chọn loại xe',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              if (fareEstimate != null)
                const Text(
                  'Đã gồm phụ phí hiện tại',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < _vehicles.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _VehicleCard(
                option: _vehicles[index],
                selected: index == _selectedVehicle,
                priceText: base > 0
                    ? '${_formatPrice(base * _vehicles[index].multiplier)}đ'
                    : '--',
                onTap: () => setState(() => _selectedVehicle = index),
              ),
            ),
          const SizedBox(height: 8),
          GradientButton(
            label: base > 0
                ? 'Đặt xe ngay • ${_formatPrice(selectedPrice)}đ'
                : 'Đặt xe ngay',
            onPressed: canBook && !widget.isLoading ? widget.onBookRide : null,
            icon: Icons.arrow_forward_rounded,
          ),
        ],
      ),
    );
  }
}

class _VehicleOption {
  final String type;
  final String label;
  final String subtitle;
  final String etaText;
  final IconData icon;
  final Color tint;
  final Color iconColor;
  final double multiplier;

  const _VehicleOption({
    required this.type,
    required this.label,
    required this.subtitle,
    required this.etaText,
    required this.icon,
    required this.tint,
    required this.iconColor,
    required this.multiplier,
  });
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;
  final bool loading;

  const _MessageCard({
    required this.icon,
    required this.color,
    required this.message,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          if (loading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            )
          else
            Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.9)),
      ),
      child: IntrinsicHeight(
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
                    label: 'Điểm đón',
                    address: pickupAddress,
                    placeholder: !hasPickup,
                    onTap: onPickupTap,
                  ),
                  const SizedBox(height: 14),
                  _LocationRow(
                    label: 'Điểm đến',
                    address: dropoffAddress,
                    placeholder: !hasDropoff,
                    onTap: onDropoffTap,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                onPressed: onSwap,
                tooltip: 'Đổi điểm đón và điểm đến',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.backgroundLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(
                  Icons.swap_vert_rounded,
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

class _ConnectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    const topY = 12.0;
    final bottomY = size.height - 12.0;

    final pickupPaint = Paint()..color = AppColors.success;
    canvas.drawCircle(Offset(centerX, topY), 5, pickupPaint);
    canvas.drawCircle(
      Offset(centerX, topY),
      5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final dropoffPaint = Paint()..color = AppColors.error;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 5, bottomY - 5, 10, 10),
        const Radius.circular(2),
      ),
      dropoffPaint,
    );

    final dashPaint = Paint()
      ..color = AppColors.borderLight
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    var y = topY + 10;
    while (y < bottomY - 8) {
      canvas.drawLine(Offset(centerX, y), Offset(centerX, y + 4), dashPaint);
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
    return Material(
      color: AppColors.backgroundLight,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: placeholder ? FontWeight.w600 : FontWeight.w700,
                  color: placeholder
                      ? AppColors.textSecondaryLight
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
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
    return Material(
      color: selected ? AppColors.primary.withValues(alpha: 0.06) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.borderLight,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: option.tint,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(option.icon, color: option.iconColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            option.label,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        if (selected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Đã chọn',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Đến sau ${option.etaText}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
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

class _FareMeta extends StatelessWidget {
  final String label;
  final String value;

  const _FareMeta({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
