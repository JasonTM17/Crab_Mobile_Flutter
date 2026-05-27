import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/location_model.dart';
import '../bloc/ride_bloc.dart';
import '../bloc/ride_event.dart';
import '../bloc/ride_state.dart';
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
          title: 'Chọn điểm đón',
          hint: 'Nhập tên toà nhà, khu vực hoặc địa chỉ',
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
          title: 'Chọn điểm đến',
          hint: 'Bạn muốn đến đâu?',
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

  void _swapLocations() {
    if (_pickup == null && _dropoff == null) return;
    setState(() {
      final tmp = _pickup;
      _pickup = _dropoff;
      _dropoff = tmp;
    });
    if (_pickup != null) {
      context.read<RideBloc>().add(PickupLocationSelected(location: _pickup!));
    }
    if (_dropoff != null) {
      context
          .read<RideBloc>()
          .add(DropoffLocationSelected(location: _dropoff!));
    }
    if (_pickup != null && _dropoff != null) {
      context.read<RideBloc>().add(
            EstimateFareRequested(pickup: _pickup!, dropoff: _dropoff!),
          );
      _fitBounds();
    }
  }

  void _bookRide(String vehicleType) {
    if (_pickup == null || _dropoff == null) return;
    context.read<RideBloc>().add(RequestRide(
          pickup: _pickup!,
          dropoff: _dropoff!,
          vehicleType: vehicleType,
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
            return TrackingMap.fromState(state: state);
          }

          final fareEstimate = state is RideIdle ? state.fareEstimate : null;
          final errorMessage = state is RideError ? state.message : null;
          final isLoading = state is RideLoading;

          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration:
                      const BoxDecoration(color: AppColors.backgroundLight),
                  child: GoogleMap(
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
                    padding: const EdgeInsets.only(bottom: 260),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.12),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.08),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MapActionButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MapStatusCard(
                          title: _pickup == null || _dropoff == null
                              ? 'Chọn lộ trình của bạn'
                              : 'Kiểm tra giá và chọn loại xe',
                          subtitle: isLoading
                              ? 'Đang cập nhật lộ trình và giá cước phù hợp.'
                              : errorMessage ??
                                  'Crab sẽ gợi ý lựa chọn phù hợp theo quãng đường của bạn.',
                          isError: errorMessage != null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state is RideSearchingDriver)
                _buildSearchingOverlay()
              else
                DraggableScrollableSheet(
                  initialChildSize: 0.38,
                  minChildSize: 0.38,
                  maxChildSize: 0.95,
                  snap: true,
                  snapSizes: const [0.38, 0.72, 0.95],
                  builder: (context, scrollController) {
                    return RideBottomSheet(
                      scrollController: scrollController,
                      pickup: _pickup,
                      dropoff: _dropoff,
                      fareEstimate: fareEstimate,
                      onPickupTap: _selectPickup,
                      onDropoffTap: _selectDropoff,
                      onBookRide: _bookRide,
                      onSwap: _swapLocations,
                      isLoading: isLoading,
                      errorMessage: errorMessage,
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchingOverlay() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.54),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.32),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_taxi_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Đang gửi yêu cầu chuyến đi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Crab đang kiểm tra lộ trình và gửi yêu cầu đến tài xế phù hợp.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 18,
                        color: AppColors.warning,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bạn có thể huỷ yêu cầu trước khi tài xế xác nhận chuyến.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      final state = context.read<RideBloc>().state;
                      if (state is RideSearchingDriver) {
                        context
                            .read<RideBloc>()
                            .add(CancelRide(rideId: state.ride.id));
                      }
                    },
                    child: const Text('Huỷ yêu cầu'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: AppColors.textPrimaryLight),
      ),
    );
  }
}

class _MapStatusCard extends StatelessWidget {
  const _MapStatusCard({
    required this.title,
    required this.subtitle,
    this.isError = false,
  });

  final String title;
  final String subtitle;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final accentColor = isError ? AppColors.error : AppColors.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isError ? Icons.error_outline_rounded : Icons.route_rounded,
              color: accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
