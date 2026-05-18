import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/models/location_model.dart';
import '../bloc/ride_state.dart';
import 'driver_info_card.dart';

class TrackingMap extends StatefulWidget {
  final RideState state;

  const TrackingMap({super.key, required this.state});

  @override
  State<TrackingMap> createState() => _TrackingMapState();
}

class _TrackingMapState extends State<TrackingMap> {
  GoogleMapController? _mapController;

  Set<Marker> _buildMarkers(RideState state) {
    final markers = <Marker>{};

    LocationModel? pickup;
    LocationModel? dropoff;
    LocationModel? driverLocation;

    if (state is RidePickup) {
      pickup = state.ride.pickup;
      dropoff = state.ride.dropoff;
      driverLocation = state.driverLocation;
    } else if (state is RideInProgress) {
      pickup = state.ride.pickup;
      dropoff = state.ride.dropoff;
      driverLocation = state.driverLocation;
    } else if (state is RideDriverMatched) {
      pickup = state.ride.pickup;
      dropoff = state.ride.dropoff;
    }

    if (pickup != null) {
      markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(pickup.latitude, pickup.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: pickup.name ?? 'Pickup'),
      ));
    }

    if (dropoff != null) {
      markers.add(Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(dropoff.latitude, dropoff.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: dropoff.name ?? 'Destination'),
      ));
    }

    if (driverLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: LatLng(driverLocation.latitude, driverLocation.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Driver'),
      ));

      // Follow driver with camera
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(driverLocation.latitude, driverLocation.longitude),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines(RideState state) {
    LocationModel? pickup;
    LocationModel? dropoff;
    LocationModel? driverLocation;

    if (state is RidePickup) {
      pickup = state.ride.pickup;
      dropoff = state.ride.dropoff;
      driverLocation = state.driverLocation;
    } else if (state is RideInProgress) {
      pickup = state.ride.pickup;
      dropoff = state.ride.dropoff;
      driverLocation = state.driverLocation;
    }

    if (pickup == null || dropoff == null) return {};

    final points = <LatLng>[];
    if (driverLocation != null) {
      points.add(LatLng(driverLocation.latitude, driverLocation.longitude));
    }
    points.add(LatLng(pickup.latitude, pickup.longitude));
    points.add(LatLng(dropoff.latitude, dropoff.longitude));

    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: const Color(0xFF1976D2),
        width: 4,
      ),
    };
  }

  LatLng _initialPosition(RideState state) {
    if (state is RidePickup) {
      return LatLng(
        state.ride.pickup.latitude,
        state.ride.pickup.longitude,
      );
    }
    if (state is RideInProgress) {
      return LatLng(
        state.ride.pickup.latitude,
        state.ride.pickup.longitude,
      );
    }
    if (state is RideDriverMatched) {
      return LatLng(
        state.ride.pickup.latitude,
        state.ride.pickup.longitude,
      );
    }
    return const LatLng(10.7769, 106.7009);
  }

  String _statusLabel(RideState state) {
    if (state is RideDriverMatched) return 'Driver is on the way';
    if (state is RidePickup) return 'Driver is arriving';
    if (state is RideInProgress) return 'On the way to destination';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _initialPosition(state),
            zoom: 14,
          ),
          onMapCreated: (controller) => _mapController = controller,
          markers: _buildMarkers(state),
          polylines: _buildPolylines(state),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),
        // Status bar overlay
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_taxi,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _statusLabel(state),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Driver info bottom sheet
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomInfo(state),
        ),
      ],
    );
  }

  Widget _buildBottomInfo(RideState state) {
    if (state is RideDriverMatched) {
      return DriverInfoCard(
        driver: state.driver,
        statusLabel: 'Driver matched!',
      );
    }
    if (state is RidePickup) {
      return DriverInfoCard(
        driver: state.driver,
        etaMinutes: state.etaMinutes,
        statusLabel: 'Driver is arriving',
      );
    }
    if (state is RideInProgress) {
      return DriverInfoCard(
        driver: state.driver,
        statusLabel: 'On the way to destination',
      );
    }
    return const SizedBox.shrink();
  }
}
