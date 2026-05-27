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
  final ValueChanged<String> onBookRide;
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
  int _selectedVehicle = 0;

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
      badge: 'Gợi ý',
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
      badge: 'Phổ biến',
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
      badge: 'Nhóm',
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
    final theme = Theme.of(context);
    final canBook = widget.pickup != null && widget.dropoff != null;
    final fareEstimate = widget.fareEstimate;
    final base = _basePrice();
    final selected = _vehicles[_selectedVehicle];
    final selectedPrice = base * selected.multiplier;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
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
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Đặt xe rõ giá',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const _MiniBadge(
                icon: Icons.verified_rounded,
                label: 'CrabRide',
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            canBook
                ? 'Kiểm tra lộ trình, chọn xe và xác nhận trong một bước.'
                : 'Thêm điểm đón và điểm đến để xem giá, ETA và lựa chọn xe.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
              height: 1.35,
            ),
          ),
          if (widget.errorMessage != null &&
              widget.errorMessage!.isNotEmpty) ...[
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
                    label: 'Giá tham chiếu',
                    value: '${_formatPrice(base)}đ',
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          _TrustChipRow(
              etaText: selected.etaText, hasFare: fareEstimate != null),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Chọn loại xe',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (fareEstimate != null)
                Text(
                  'Đã gồm phụ phí hiện tại',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w700,
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
                ? 'Đặt xe ngay · ${_formatPrice(selectedPrice)}đ'
                : 'Đặt xe ngay',
            onPressed: canBook && !widget.isLoading
                ? () => widget.onBookRide(selected.type)
                : null,
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
  final String badge;

  const _VehicleOption({
    required this.type,
    required this.label,
    required this.subtitle,
    required this.etaText,
    required this.icon,
    required this.tint,
    required this.iconColor,
    required this.multiplier,
    required this.badge,
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
    final theme = Theme.of(context);

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
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.35,
                fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.9)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
                width: 24, child: CustomPaint(painter: _ConnectorPainter())),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                children: [
                  _LocationRow(
                    label: 'Điểm đón',
                    address: pickupAddress,
                    placeholder: !hasPickup,
                    onTap: onPickupTap,
                  ),
                  const SizedBox(height: 10),
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
                  backgroundColor: Colors.white,
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
    final theme = Theme.of(context);

    return Material(
      color: Colors.white,
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
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondaryLight,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: placeholder ? FontWeight.w600 : FontWeight.w800,
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
    final theme = Theme.of(context);

    return Material(
      color:
          selected ? AppColors.primary.withValues(alpha: 0.06) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: option.tint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(option.icon, color: option.iconColor, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            option.label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        _MiniBadge(
                          icon: selected
                              ? Icons.check_rounded
                              : Icons.schedule_rounded,
                          label: selected ? 'Đã chọn' : option.badge,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondaryLight,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _InlineMeta(
                          icon: Icons.timer_rounded,
                          label: option.etaText,
                        ),
                        _InlineMeta(
                          icon: Icons.payments_outlined,
                          label: priceText,
                        ),
                      ],
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

class _FareMeta extends StatelessWidget {
  final String label;
  final String value;

  const _FareMeta({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondaryLight,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimaryLight,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustChipRow extends StatelessWidget {
  const _TrustChipRow({required this.etaText, required this.hasFare});

  final String etaText;
  final bool hasFare;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        _TrustChip(
          icon: Icons.verified_user_outlined,
          label: hasFare ? 'Giá rõ ràng' : 'Ước tính tức thì',
          color: AppColors.primary,
        ),
        _TrustChip(
          icon: Icons.timer_rounded,
          label: 'Đón $etaText',
          color: AppColors.info,
        ),
        const _TrustChip(
          icon: Icons.support_agent_rounded,
          label: 'Hỗ trợ trong app',
          color: AppColors.accent,
        ),
      ],
    );
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineMeta extends StatelessWidget {
  const _InlineMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondaryLight),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
