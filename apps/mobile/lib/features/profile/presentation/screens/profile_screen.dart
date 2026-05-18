import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: ListView(
            children: [
              const SizedBox(height: 24),
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(0xFF00B14F).withOpacity(0.1),
                  child: const Icon(
                    Icons.person,
                    size: 48,
                    color: Color(0xFF00B14F),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  user?.fullName ?? 'User',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Center(child: Text(user?.email ?? '')),
              const SizedBox(height: 32),
              const _SectionTitle('Account'),
              _Item(
                icon: Icons.person,
                label: 'Edit profile',
                onTap: () {},
              ),
              _Item(
                icon: Icons.location_on,
                label: 'Saved addresses',
                onTap: () {},
              ),
              _Item(
                icon: Icons.payment,
                label: 'Payment methods',
                onTap: () => context.push('/wallet'),
              ),
              _Item(
                icon: Icons.lock,
                label: 'Change password',
                onTap: () {},
              ),
              const _SectionTitle('Preferences'),
              _Item(
                icon: Icons.notifications,
                label: 'Notifications',
                onTap: () {},
              ),
              _Item(
                icon: Icons.language,
                label: 'Language',
                onTap: () {},
              ),
              _Item(
                icon: Icons.dark_mode,
                label: 'Theme',
                onTap: () {},
              ),
              const _SectionTitle('Support'),
              _Item(icon: Icons.help, label: 'Help center', onTap: () {}),
              _Item(icon: Icons.info, label: 'About', onTap: () {}),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    context
                        .read<AuthBloc>()
                        .add(const AuthLogoutRequested());
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Item({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
