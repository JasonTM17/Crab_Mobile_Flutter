import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/models/location_model.dart';
import '../bloc/ride_bloc.dart';
import '../bloc/ride_event.dart';
import '../bloc/ride_state.dart';
import '../widgets/driver_info_card.dart';
import '../widgets/ride_bottom_sheet.dart';
import '../widgets/tracking_map.dart';
import 'location_search_screen.dart';

class RideBookingScreen extends StatefulWidget {
  const RideBookingScreen({super.key});

  @override
  State<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends State<RideBookingScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  late AnimationController _searchingAnimController;
  late Animation<double> _pulseAnimation;

  // Default to Ho Chi Minh City center
  static const LatLng _defaultCenter = LatLng(10.7769, 106.7009);

  LocationModel? _pickup;
  LocationModel? _dropoff;

  @override
  void initState() {
    super.initState();
    _searchingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _searchingAnimController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _searchingAnimController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    if (_pickup != null) {
      markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(_pickup!.latitude, _pickup!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: _pickup!.name ?? 'Pickup'),
      ));
    }
    if (_dropoff != null) {
      markers.add(Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(_dropoff!.latitude, _dropoff!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: _dropoff!.name ?? 'Dropoff'),
      ));
    }
    return markers;
  }

  Set<Polyline> _buildPolylines() {
    if (_pickup == null || _dropoff == null) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: [
          LatLng(_pickup!.latitude, _pickup!.longitude),
          LatLng(_dropoff!.latitude, _dropoff!.longitude),
        ],
        color: const Color(0xFF1976D2),
        width: 4,
      ),
    };
  }

  void _fitBounds() {
    if (_mapController == null || _pickup == null || _dropoff == null) return;
    final bounds = LatLngBounds(
      southwest: LatLng(
        _pickup!.latitude < _dropoff!.latitude
            ? _pickup!.latitude
            : _dropoff!.latitude,
        _pickup!.longitude < _dropoff!.longitude
            ? _pickup!.longitude
            : _dropoff!.longitude,
      ),
      northeast: LatLng(
        _pickup!.latitude > _dropoff!.latitude
            ? _pickup!.latitude
            : _dropoff!.latitude,
        _pickup!.longitude > _dropoff!.longitude
            ? _pickup!.longitude
            : _dropoff!.longitude,
      ),
    );
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  Future<void> _selectPickup() async {
    final result = await Navigator.push<LocationModel>(
      context,
      MaterialPageRoute(
        builder: (_) => const LocationSearchScreen(
          title: 'Select Pickup',
          hint: 'Where are you?',
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => _pickup = result);
      context.read<RideBloc>().add(PickupLocationSelected(location: result));
      if (_dropoff != null) {
        context.read<RideBloc>().add(EstimateFareRequested(
              pickup: result,
              dropoff: _dropoff!,
            ));
        _fitBounds();
      }
    }
  }

  Future<void> _selectDropoff() async {
    final result = await Navigator.push<LocationModel>(
      context,
      MaterialPageRoute(
        builder: (_) => const LocationSearchScreen(
          title: 'Select Destination',
          hint: 'Where to?',
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => _dropoff = result);
      context.read<RideBloc>().add(DropoffLocationSelected(location: result));
      if (_pickup != null) {
        context.read<RideBloc>().add(EstimateFareRequested(
              pickup: _pickup!,
              dropoff: result,
            ));
        _fitBounds();
      }
    }
  }

  void _bookRide() {
    if (_pickup == null || _dropoff == null) return;
    context.read<RideBloc>().add(RequestRide(
          pickup: _pickup!,
          dropoff: _dropoff!,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RideBloc, RideState>(
        builder: (context, state) {
          if (state is RidePickup ||
              state is RideInProgress ||
              state is RideDriverMatched) {
            return TrackingMap(state: state);
          }

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _defaultCenter,
                  zoom: 13,
                ),
                onMapCreated: (controller) => _mapController = controller,
                markers: _buildMarkers(),
                polylines: _buildPolylines(),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
              // Floating translucent back button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      iconSize: 20,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
              // Bottom sheet
              if (state is RideSearchingDriver)
                _buildSearchingOverlay()
              else
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: RideBottomSheet(
                    pickup: _pickup,
                    dropoff: _dropoff,
                    fareEstimate:
                        state is RideIdle ? state.fareEstimate : null,
                    onPickupTap: _selectPickup,
                    onDropoffTap: _selectDropoff,
                    onBookRide: _bookRide,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_taxi,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Searching for driver...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please wait a moment',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () {
                final state = context.read<RideBloc>().state;
                if (state is RideSearchingDriver) {
                  context
                      .read<RideBloc>()
                      .add(CancelRide(rideId: state.ride.id));
                }
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
