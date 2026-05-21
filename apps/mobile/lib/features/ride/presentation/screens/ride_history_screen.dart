import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/services/auth_storage.dart';
import '../../data/models/ride_models.dart';
import '../../data/repositories/ride_repository.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  late Future<List<Ride>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Ride>> _load() async {
    final riderId = await sl<AuthStorage>().getUserId();
    if (riderId == null || riderId.isEmpty) return [];
    return sl<RideRepository>().getMyRides(riderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ride History')),
      body: FutureBuilder<List<Ride>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _MessageState(
              icon: Icons.error_outline,
              title: 'Could not load rides',
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final rides = snapshot.data ?? [];
          if (rides.isEmpty) {
            return const _MessageState(
              icon: Icons.route_outlined,
              title: 'No rides yet',
              message: 'Completed and cancelled rides will appear here.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => setState(() => _future = _load()),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rides.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _RideTile(ride: rides[index]),
            ),
          );
        },
      ),
    );
  }
}

class _RideTile extends StatelessWidget {
  const _RideTile({required this.ride});
  final Ride ride;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (ride.status) {
      RideStatus.completed => Colors.green,
      RideStatus.cancelled => Colors.red,
      _ => Theme.of(context).colorScheme.primary,
    };
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Theme.of(context).colorScheme.surface,
      leading: CircleAvatar(
        backgroundColor: statusColor.withValues(alpha: 0.12),
        child: Icon(Icons.local_taxi_rounded, color: statusColor),
      ),
      title: Text(ride.dropoff.address ?? 'Destination'),
      subtitle: Text(
        '${ride.status.label} • ${ride.distanceKm.toStringAsFixed(1)} km',
      ),
      trailing: Text(
        '${ride.fare}d',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      onTap: () => context.push('/ride/${ride.id}'),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
