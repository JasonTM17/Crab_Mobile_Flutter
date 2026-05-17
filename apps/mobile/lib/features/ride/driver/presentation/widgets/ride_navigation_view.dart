import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../data/models/ride_model.dart';
import '../bloc/driver_bloc.dart';
import '../bloc/driver_event.dart';
import '../bloc/driver_state.dart';

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
  GoogleMapController? _mapController;

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
          onMapCreated: (c) => _mapController = c,
          markers: _buildMarkers(),
          polylines: _buildPolylines(),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),
        // Navigation header
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.isPickupPhase ? Colors.green : Colors.blue,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isPickupPhase
                        ? Icons.person_pin_circle
                        : Icons.flag,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.isPickupPhase
                          ? 'Navigate to pickup'
                          : 'Navigate to destination',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
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
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
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
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Pickup address
              _AddressRow(
                icon: Icons.circle,
                iconColor: Colors.green,
                address: widget.ride.pickup.address ??
                    widget.ride.pickup.name ??
                    'Pickup',
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Container(
                  height: 16,
                  width: 2,
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              // Dropoff address
              _AddressRow(
                icon: Icons.location_on,
                iconColor: Colors.red,
                address: widget.ride.dropoff.address ??
                    widget.ride.dropoff.name ??
                    'Destination',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
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
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        widget.isPickupPhase ? Colors.green : Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.isPickupPhase
                        ? 'Passenger Picked Up'
                        : 'Complete Ride',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
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

class _AddressRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String address;

  const _AddressRow({
    required this.icon,
    required this.iconColor,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            address,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
