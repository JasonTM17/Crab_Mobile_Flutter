import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/gradient_button.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is PasswordChanged) {
          _currentController.clear();
          _newController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed')),
          );
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final loading = state is ProfileLoading;
        return Scaffold(
          appBar: AppBar(title: const Text('Security')),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextField(
                controller: _currentController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current password',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _newController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New password',
                  prefixIcon: Icon(Icons.lock_rounded),
                ),
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: 'Change Password',
                icon: Icons.security_rounded,
                loading: loading,
                onPressed: loading
                    ? null
                    : () => context.read<ProfileBloc>().add(
                          ChangePassword(
                            currentPassword: _currentController.text,
                            newPassword: _newController.text,
                          ),
                        ),
              ),
            ],
          ),
        );
      },
    );
  }
}
