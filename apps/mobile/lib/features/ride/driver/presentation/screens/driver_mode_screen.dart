import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/driver_bloc.dart';
import '../bloc/driver_event.dart';
import '../bloc/driver_state.dart';
import '../widgets/incoming_ride_card.dart';
import '../widgets/ride_navigation_view.dart';

class DriverModeScreen extends StatelessWidget {
  const DriverModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverBloc, DriverState>(
      listener: (context, state) {
        if (state is DriverError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is DriverNavigatingToPickup) {
          return RideNavigationView(
            ride: state.ride,
            isPickupPhase: true,
          );
        }

        if (state is DriverInRide) {
          return RideNavigationView(
            ride: state.ride,
            isPickupPhase: false,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Driver Mode'),
            actions: [
              if (state is DriverOnlineIdle || state is DriverRideRequest)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ONLINE',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: Stack(
            children: [
              // Main content
              _buildMainContent(context, state),
              // Incoming ride overlay
              if (state is DriverRideRequest)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IncomingRideCard(
                    rideRequest: state.rideRequest,
                    countdown: state.countdown,
                    onAccept: () => context
                        .read<DriverBloc>()
                        .add(AcceptRide(rideId: state.rideRequest.id)),
                    onReject: () => context
                        .read<DriverBloc>()
                        .add(RejectRide(rideId: state.rideRequest.id)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context, DriverState state) {
    if (state is DriverOffline) {
      return _OfflineView(
        onGoOnline: () =>
            context.read<DriverBloc>().add(const GoOnline()),
      );
    }

    if (state is DriverOnlineIdle) {
      return const _WaitingView();
    }

    if (state is DriverRideRequest) {
      return const _WaitingView();
    }

    return const SizedBox.shrink();
  }
}

class _OfflineView extends StatelessWidget {
  final VoidCallback onGoOnline;

  const _OfflineView({required this.onGoOnline});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_taxi,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'You are offline',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Go online to start receiving ride requests',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onGoOnline,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Go Online',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaitingView extends StatefulWidget {
  const _WaitingView();

  @override
  State<_WaitingView> createState() => _WaitingViewState();
}

class _WaitingViewState extends State<_WaitingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_taxi,
                size: 56,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Waiting for rides...',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You will be notified when a ride is available',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 48),
          TextButton.icon(
            onPressed: () =>
                context.read<DriverBloc>().add(const GoOffline()),
            icon: const Icon(Icons.power_settings_new, color: Colors.red),
            label: const Text(
              'Go Offline',
              style: TextStyle(color: Colors.red, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
