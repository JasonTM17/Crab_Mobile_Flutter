import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/service_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          context.go('/login');
        }
      },
      builder: (context, state) {
        final name = state.user?.firstName ?? 'there';
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello, $name', style: Theme.of(context).textTheme.headlineMedium),
                          Text('Where to today?', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () => context.push('/notifications'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_wallet, color: Color(0xFF00B14F)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Wallet Balance', style: TextStyle(fontSize: 12)),
                                Text('0 VND', style: Theme.of(context).textTheme.titleLarge),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => context.push('/wallet'),
                            child: const Text('Top up'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Services', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  const ServiceGrid(),
                  const SizedBox(height: 24),
                  Text('Promotions', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _PromoBanner(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: 0,
            onDestinationSelected: (i) {
              if (i == 1) context.push('/activity');
              if (i == 2) context.push('/chat');
              if (i == 3) context.push('/profile');
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.history), label: 'Activity'),
              NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
              NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            label: const Text('Logout'),
            icon: const Icon(Icons.logout),
          ),
        );
      },
    );
  }
}

class _PromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00B14F), Color(0xFF008F3F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '50% OFF',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'First ride with code WELCOME50',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const Icon(Icons.local_offer, color: Colors.white, size: 64),
        ],
      ),
    );
  }
}
