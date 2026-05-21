import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/location_model.dart';
import '../bloc/ride_state.dart';

class TrackingMap extends StatefulWidget {
  final LocationModel? pickup;
  final LocationModel? dropoff;
  final LocationModel? driverLocation;

  const TrackingMap({
    super.key,
    this.pickup,
    this.dropoff,
    this.driverLocation,
  });

  factory TrackingMap.fromState({Key? key, required RideState state}) {
    LocationModel? pickup;
    LocationModel? dropoff;
    LocationModel? driver;

    if (state is RidePickup) {
      pickup = state.ride.pickup;
      dropoff = state.ride.dropoff;
      driver = state.driverLocation;
    } else if (state is RideInProgress) {
      pickup = state.ride.pickup;
      dropoff = state.ride.dropoff;
      driver = state.driverLocation;
    } else if (state is RideDriverMatched) {
      pickup = state.ride.pickup;
      dropoff = state.ride.dropoff;
    }

    return TrackingMap(
      key: key,
      pickup: pickup,
      dropoff: dropoff,
      driverLocation: driver,
    );
  }

  @override
  State<TrackingMap> createState() => _TrackingMapState();
}

class _TrackingMapState extends State<TrackingMap>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  AnimationController? _moveCtrl;
  AnimationController? _pulseCtrl;

  LatLng? _animatedDriverPos;
  LatLng? _previousDriverPos;
  Offset? _driverScreenOffset;

  @override
  void initState() {
    super.initState();
    _moveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addListener(_onMoveTick);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _initDriver();
  }

  @override
  void didUpdateWidget(covariant TrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.driverLocation;
    final prev = oldWidget.driverLocation;
    if (next != null && next != prev) {
      _animateDriverTo(next);
    }
  }

  @override
  void dispose() {
    _moveCtrl?.removeListener(_onMoveTick);
    _moveCtrl?.dispose();
    _pulseCtrl?.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _initDriver() {
    final loc = widget.driverLocation;
    if (loc != null) {
      _animatedDriverPos = LatLng(loc.latitude, loc.longitude);
    }
  }

  void _animateDriverTo(LocationModel next) {
    final newLatLng = LatLng(next.latitude, next.longitude);
    _previousDriverPos = _animatedDriverPos ?? newLatLng;
    _moveCtrl?.forward(from: 0);
    _mapController?.animateCamera(CameraUpdate.newLatLng(newLatLng));
  }

  void _onMoveTick() {
    if (_previousDriverPos == null || _moveCtrl == null) return;
    final t = _moveCtrl!.value;
    final next = widget.driverLocation;
    if (next == null) return;
    final lat = _lerp(_previousDriverPos!.latitude, next.latitude, t);
    final lng = _lerp(_previousDriverPos!.longitude, next.longitude, t);
    setState(() => _animatedDriverPos = LatLng(lat, lng));
    _refreshDriverScreenPos();
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  Future<void> _refreshDriverScreenPos() async {
    final ctrl = _mapController;
    final pos = _animatedDriverPos;
    if (ctrl == null || pos == null) return;
    if (!mounted) return;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    try {
      final screen = await ctrl.getScreenCoordinate(pos);
      if (!mounted) return;
      setState(() {
        _driverScreenOffset =
            Offset(screen.x.toDouble() / dpr, screen.y.toDouble() / dpr);
      });
    } catch (_) {
      // ignore projection errors
    }
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    final pickup = widget.pickup;
    final dropoff = widget.dropoff;

    if (pickup != null) {
      markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(pickup.latitude, pickup.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: pickup.name ?? 'Diem don'),
      ));
    }
    if (dropoff != null) {
      markers.add(Marker(
        markerId: const MarkerId('dropoff'),
        position: LatLng(dropoff.latitude, dropoff.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: dropoff.name ?? 'Diem den'),
      ));
    }
    return markers;
  }

  Set<Polyline> _buildPolylines() {
    final pickup = widget.pickup;
    final dropoff = widget.dropoff;
    if (pickup == null || dropoff == null) return {};

    final points = <LatLng>[];
    if (_animatedDriverPos != null) points.add(_animatedDriverPos!);
    points.add(LatLng(pickup.latitude, pickup.longitude));
    points.add(LatLng(dropoff.latitude, dropoff.longitude));

    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: AppColors.primary,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };
  }

  LatLng _initialPosition() {
    if (_animatedDriverPos != null) return _animatedDriverPos!;
    if (widget.pickup != null) {
      return LatLng(widget.pickup!.latitude, widget.pickup!.longitude);
    }
    return const LatLng(10.7769, 106.7009);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition:
              CameraPosition(target: _initialPosition(), zoom: 15),
          onMapCreated: (controller) {
            _mapController = controller;
            if (_animatedDriverPos != null) {
              controller.animateCamera(
                CameraUpdate.newLatLng(_animatedDriverPos!),
              );
              _refreshDriverScreenPos();
            }
          },
          onCameraIdle: _refreshDriverScreenPos,
          markers: _buildMarkers(),
          polylines: _buildPolylines(),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: false,
        ),
        if (_driverScreenOffset != null && _animatedDriverPos != null)
          Positioned(
            left: _driverScreenOffset!.dx - 22,
            top: _driverScreenOffset!.dy - 22,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _pulseCtrl!,
                builder: (_, __) {
                  final t = _pulseCtrl!.value;
                  return SizedBox(
                    width: 44,
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: (1 - t).clamp(0.0, 1.0),
                          child: Container(
                            width: 16 + 24 * t,
                            height: 16 + 24 * t,
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(alpha: 0.35),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary
                                    .withValues(alpha: 0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
