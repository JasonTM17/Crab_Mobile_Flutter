import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/models/driver_model.dart';
import '../../data/models/location_model.dart';
import '../bloc/ride_state.dart';

class TrackingMap extends StatefulWidget {
  final RideState state;

  const TrackingMap({super.key, required this.state});

  @override
  State<TrackingMap> createState() => _TrackingMapState();
}

class _TrackingMapState extends State<TrackingMap>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;

  // Animated driver position
  LatLng? _animatedDriverPos;
  LatLng? _previousDriverPos;
  AnimationController? _markerAnimController;
  Animation<double>? _markerAnim;

  @override
  void initState() {
    super.initState();
    _markerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _markerAnim = CurvedAnimation(
      parent: _markerAnimController!,
      curve: Curves.easeInOut,
    );
    _markerAnim!.addListener(_onMarkerAnimTick);
    _initDriverPosition(widget.state);
  }

  @override
  void didUpdateWidget(TrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newPos = _extractDriverLocation(widget.state);
    final oldPos = _extractDriverLocation(oldWidget.state);

    if (newPos != null && newPos != oldPos) {
      _animateDriverTo(newPos);
    }
  }

  @override
  void dispose() {
    _markerAnim?.removeListener(_onMarkerAnimTick);
    _markerAnimController?.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _initDriverPosition(RideState state) {
    final pos = _extractDriverLocation(state);
    if (pos != null) {
      _animatedDriverPos = LatLng(pos.latitude, pos.longitude);
    }
  }

  LocationModel? _extractDriverLocation(RideState state) {
    if (state is RidePickup) return state.driverLocation;
    if (state is RideInProgress) return state.driverLocation;
    return null;
  }

  void _animateDriverTo(LocationModel newLoc) {
    final newLatLng = LatLng(newLoc.latitude, newLoc.longitude);
    _previousDriverPos = _animatedDriverPos ?? newLatLng;
    _markerAnimController!.forward(from: 0);

    // Follow camera
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(newLatLng),
    );
  }

  void _onMarkerAnimTick() {
    if (_previousDriverPos == null || _markerAnim == null) return;
    final t = _markerAnim!.value;
    final prev = _previousDriverPos!;
    final newPos = _extractDriverLocation(widget.state);
    if (newPos == null) return;

    setState(() {
      _animatedDriverPos = LatLng(
        _lerp(prev.latitude, newPos.latitude, t),
        _lerp(prev.longitude, newPos.longitude, t),
      );
    });
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  Set<Marker> _buildMarkers(RideState state) {
    final markers = <Marker>{};

    LocationModel? pickup;
    LocationModel? dropoff;

    if (state is RidePickup) {
      pickup = state.ride.pickup;
      dropoff = state.ride.dropoff;
    } else if (state is RideInProgress) {
      pickup = state.ride.pickup;
      dropoff = state.ride.dropoff;
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

    if (_animatedDriverPos != null) {
      markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: _animatedDriverPos!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Driver'),
        zIndex: 2,
      ));
    }

    return markers;
  }

  Set<Polyline> _buildPolylines(RideState state) {
    LocationModel? pickup;
    LocationModel? dropoff;

    if (state is RidePickup) {
      pickup = state.ride.pickup;
      dropoff = state.ride.dropoff;
    } else if (state is RideInProgress) {
      pickup = state.ride.pickup;
      dropoff = state.ride.dropoff;
    }

    if (pickup == null || dropoff == null) return {};

    final points = <LatLng>[];
    if (_animatedDriverPos != null) {
      points.add(_animatedDriverPos!);
    }
    points.add(LatLng(pickup.latitude, pickup.longitude));
    points.add(LatLng(dropoff.latitude, dropoff.longitude));

    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: const Color(0xFF1976D2),
        width: 4,
        patterns: [],
      ),
    };
  }

  LatLng _initialPosition(RideState state) {
    if (state is RidePickup) {
      return LatLng(state.ride.pickup.latitude, state.ride.pickup.longitude);
    }
    if (state is RideInProgress) {
      return LatLng(state.ride.pickup.latitude, state.ride.pickup.longitude);
    }
    if (state is RideDriverMatched) {
      return LatLng(state.ride.pickup.latitude, state.ride.pickup.longitude);
    }
    return const LatLng(10.7769, 106.7009);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _initialPosition(state),
            zoom: 15,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            // Center on driver if already known
            if (_animatedDriverPos != null) {
              controller.animateCamera(
                CameraUpdate.newLatLng(_animatedDriverPos!),
              );
            }
          },
          markers: _buildMarkers(state),
          polylines: _buildPolylines(state),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),
        // Status bar
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _StatusBar(state: state),
          ),
        ),
        // Driver info + ETA bottom panel
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomPanel(state),
        ),
      ],
    );
  }

  Widget _buildBottomPanel(RideState state) {
    if (state is RideDriverMatched) {
      return _DriverPanel(
        driver: state.driver,
        statusLabel: 'Driver matched!',
      );
    }
    if (state is RidePickup) {
      return _DriverPanel(
        driver: state.driver,
        etaMinutes: state.etaMinutes,
        statusLabel: 'Driver is arriving',
      );
    }
    if (state is RideInProgress) {
      return _DriverPanel(
        driver: state.driver,
        statusLabel: 'On the way to destination',
      );
    }
    return const SizedBox.shrink();
  }
}

// ─── Status Bar ──────────────────────────────────────────────────────────────

class _StatusBar extends StatelessWidget {
  final RideState state;

  const _StatusBar({required this.state});

  String get _label {
    if (state is RideDriverMatched) return 'Driver is on the way';
    if (state is RidePickup) return 'Driver is arriving';
    if (state is RideInProgress) return 'On the way to destination';
    if (state is RideCompletedState) return 'Arrived';
    return '';
  }

  Color get _color {
    if (state is RideInProgress) return const Color(0xFF1976D2);
    if (state is RideCompletedState) return Colors.green;
    return const Color(0xFF00C853);
  }

  IconData get _icon {
    if (state is RideInProgress) return Icons.navigation;
    if (state is RideCompletedState) return Icons.check_circle;
    return Icons.local_taxi;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: _color, size: 20),
          const SizedBox(width: 8),
          Text(
            _label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Driver Panel ─────────────────────────────────────────────────────────────

class _DriverPanel extends StatelessWidget {
  final DriverModel driver;
  final int? etaMinutes;
  final String? statusLabel;

  const _DriverPanel({
    required this.driver,
    this.etaMinutes,
    this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Status chip
              if (statusLabel != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel!,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: driver.avatar != null
                        ? NetworkImage(driver.avatar!)
                        : null,
                    child: driver.avatar == null
                        ? Text(
                            driver.name.isNotEmpty
                                ? driver.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Name + rating stars
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        _StarRating(rating: driver.rating),
                        const SizedBox(height: 2),
                        Text(
                          '${driver.vehicle.color} ${driver.vehicle.model} · ${driver.vehicle.plate}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // ETA badge
                  if (etaMinutes != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$etaMinutes',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            'min',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Call button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone, size: 18),
                  label: Text('Call ${driver.name.split(' ').first}'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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

// ─── Star Rating ──────────────────────────────────────────────────────────────

class _StarRating extends StatelessWidget {
  final double rating;
  final int maxStars;

  const _StarRating({required this.rating, this.maxStars = 5});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ...List.generate(maxStars, (i) {
          final filled = i < rating.floor();
          final half = !filled && i < rating;
          return Icon(
            filled
                ? Icons.star
                : half
                    ? Icons.star_half
                    : Icons.star_border,
            color: Colors.amber,
            size: 14,
          );
        }),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

