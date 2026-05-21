import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_gradients.dart';
import '../../../../../core/theme/app_motion.dart';
import '../../../../../shared/widgets/gradient_button.dart';
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
            title: const Text(
              'Driver mode',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            elevation: 0,
            scrolledUnderElevation: 0,
            actions: [
              if (state is DriverOnlineIdle || state is DriverRideRequest)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _LiveDot(),
                          SizedBox(width: 6),
                          Text(
                            'ONLINE',
                            style: TextStyle(
                              color: Color(0xFF15803D),
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
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
        onGoOnline: () => context.read<DriverBloc>().add(const GoOnline()),
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
    final cs = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_taxi_rounded,
                size: 54,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 26),
            Text(
              "You're offline",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Go online to start receiving ride requests in your area.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 36),
            GradientButton(
              label: 'Go online',
              icon: Icons.power_settings_new_rounded,
              height: 56,
              onPressed: onGoOnline,
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
    final cs = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.36),
                      blurRadius: 26,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_taxi_rounded,
                  size: 54,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Waiting for rides…',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "We'll buzz you the moment a nearby request comes in.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 40),
          OutlinedButton.icon(
            onPressed: () => context.read<DriverBloc>().add(const GoOffline()),
            icon: const Icon(
              Icons.power_settings_new_rounded,
              size: 18,
              color: Color(0xFFEF4444),
            ),
            label: const Text(
              'Go offline',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w700,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              side: const BorderSide(
                color: Color(0xFFFECACA),
                width: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  const _LiveDot();
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: AppMotion.normal + const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color:
              const Color(0xFF22C55E).withValues(alpha: 0.5 + 0.5 * _c.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
