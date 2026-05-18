import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/models/ride_models.dart';
import '../../data/repositories/ride_repository.dart';

class BookRideScreen extends StatefulWidget {
  const BookRideScreen({super.key});

  @override
  State<BookRideScreen> createState() => _BookRideScreenState();
}

class _BookRideScreenState extends State<BookRideScreen> {
  final _pickupController = TextEditingController(text: 'Current location');
  final _dropoffController = TextEditingController();

  // Default Hanoi center
  GeoPoint _pickup = GeoPoint(latitude: 21.0285, longitude: 105.8542, address: 'Current location');
  GeoPoint? _dropoff;

  List<FareEstimate> _estimates = [];
  VehicleType _selectedType = VehicleType.bike;
  bool _loading = false;
  bool _booking = false;

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  Future<void> _loadEstimates() async {
    if (_dropoff == null) return;
    setState(() => _loading = true);
    try {
      final repo = sl<RideRepository>();
      final estimates = await repo.estimateAllTypes(pickup: _pickup, dropoff: _dropoff!);
      setState(() => _estimates = estimates);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load fares: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setDropoffMock() {
    // Mock dropoff for demo
    setState(() {
      _dropoff = GeoPoint(latitude: 21.0312, longitude: 105.8500, address: _dropoffController.text);
    });
    _loadEstimates();
  }

  Future<void> _book() async {
    if (_dropoff == null || _estimates.isEmpty) return;
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;

    setState(() => _booking = true);
    try {
      final repo = sl<RideRepository>();
      final ride = await repo.bookRide(
        riderId: user.id,
        pickup: _pickup,
        dropoff: _dropoff!,
        vehicleType: _selectedType,
      );
      if (mounted) context.go('/ride/${ride.id}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  IconData _iconFor(VehicleType t) {
    switch (t) {
      case VehicleType.bike: return Icons.motorcycle;
      case VehicleType.car4: return Icons.directions_car;
      case VehicleType.car7: return Icons.airport_shuttle;
      case VehicleType.premium: return Icons.car_rental;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Ride')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[200],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 64, color: Colors.grey),
                    Text('Map preview\n(Google Maps requires API key)', textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _pickupController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.my_location, color: Colors.green),
                      labelText: 'Pickup',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _dropoffController,
                    onSubmitted: (_) => _setDropoffMock(),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                      labelText: 'Where to?',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _setDropoffMock,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_loading) const LinearProgressIndicator(),
                  if (_estimates.isNotEmpty)
                    Expanded(
                      child: ListView.separated(
                        itemCount: _estimates.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final e = _estimates[i];
                          final selected = e.vehicleType == _selectedType;
                          return ListTile(
                            leading: Icon(_iconFor(e.vehicleType),
                                color: selected ? const Color(0xFF00B14F) : null),
                            title: Text(e.vehicleType.label),
                            subtitle: Text('${e.distanceKm.toStringAsFixed(1)} km · ${e.durationMin} min'),
                            trailing: Text(
                              '${e.totalFare.toString()} VND',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: selected ? const Color(0xFF00B14F) : null,
                              ),
                            ),
                            selected: selected,
                            onTap: () => setState(() => _selectedType = e.vehicleType),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: (_estimates.isEmpty || _booking) ? null : _book,
                    child: _booking
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Confirm Booking'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
