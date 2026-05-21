import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../core/theme/app_gradients.dart';
import '../../../../../shared/widgets/gradient_button.dart';
import '../../../data/models/ride_model.dart';
import '../bloc/driver_bloc.dart';
import '../bloc/driver_event.dart';

class RideNavigationView extends StatefulWidget {
  final RideModel ride;
  final bool isPickupPhase;

  const RideNavigationView({
    super.key,
    required this.ride,
    required this.isPickupPhase,
  });

  @override
  State<RideNavigationView> createState() => _RideNavigationViewState();
}

class _RideNavigationViewState extends State<RideNavigationView> {
  Set<Marker> _buildMarkers() {
    return {
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(
          widget.ride.pickup.latitude,
          widget.ride.pickup.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: widget.ride.pickup.name ?? 'Pickup',
        ),
      ),
      Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(
          widget.ride.dropoff.latitude,
          widget.ride.dropoff.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: widget.ride.dropoff.name ?? 'Destination',
        ),
      ),
    };
  }

  Set<Polyline> _buildPolylines() {
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: [
          LatLng(widget.ride.pickup.latitude, widget.ride.pickup.longitude),
          LatLng(widget.ride.dropoff.latitude, widget.ride.dropoff.longitude),
        ],
        color: const Color(0xFF1976D2),
        width: 4,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final targetLat = widget.isPickupPhase
        ? widget.ride.pickup.latitude
        : widget.ride.dropoff.latitude;
    final targetLng = widget.isPickupPhase
        ? widget.ride.pickup.longitude
        : widget.ride.dropoff.longitude;

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(targetLat, targetLng),
            zoom: 15,
          ),
          markers: _buildMarkers(),
          polylines: _buildPolylines(),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),
        // Navigation header
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: widget.isPickupPhase
                    ? AppGradients.primary
                    : AppGradients.ocean,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isPickupPhase
                            ? const Color(0xFF00B14F)
                            : const Color(0xFF3B82F6))
                        .withValues(alpha: 0.30),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.isPickupPhase
                          ? Icons.person_pin_circle_rounded
                          : Icons.flag_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isPickupPhase ? 'PICKUP' : 'DROPOFF',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.86),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          widget.isPickupPhase
                              ? 'Navigate to pickup'
                              : 'Navigate to destination',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Bottom action panel
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomPanel(context, theme),
        ),
      ],
    );
  }

  Widget _buildBottomPanel(BuildContext context, ThemeData theme) {
    final cs = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: cs.outlineVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _AddressRow(
                icon: Icons.radio_button_checked_rounded,
                iconColor: const Color(0xFF22C55E),
                label: 'Pickup',
                address: widget.ride.pickup.address ??
                    widget.ride.pickup.name ??
                    'Pickup',
              ),
              Padding(
                padding: const EdgeInsets.only(left: 11),
                child: Container(
                  height: 18,
                  width: 2,
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              _AddressRow(
                icon: Icons.location_on_rounded,
                iconColor: const Color(0xFFEF4444),
                label: 'Destination',
                address: widget.ride.dropoff.address ??
                    widget.ride.dropoff.name ??
                    'Destination',
              ),
              const SizedBox(height: 18),
              GradientButton(
                label: widget.isPickupPhase
                    ? 'Passenger picked up'
                    : 'Complete ride',
                icon: widget.isPickupPhase
                    ? Icons.person_add_alt_1_rounded
                    : Icons.flag_rounded,
                gradient: widget.isPickupPhase
                    ? AppGradients.primary
                    : AppGradients.ocean,
                height: 56,
                onPressed: () {
                  if (widget.isPickupPhase) {
                    context
                        .read<DriverBloc>()
                        .add(StartRide(rideId: widget.ride.id));
                  } else {
                    context
                        .read<DriverBloc>()
                        .add(CompleteRide(rideId: widget.ride.id));
                  }
                },
              ),
            ],
          ),
        ),
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
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
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
