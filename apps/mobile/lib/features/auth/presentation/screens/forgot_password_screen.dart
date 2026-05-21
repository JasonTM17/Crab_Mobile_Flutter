import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/gradient_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _codeSent = false;
  bool _obscure = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final bloc = context.read<AuthBloc>();
    final phone = _phoneController.text.trim();
    if (!_codeSent) {
      bloc.add(AuthPasswordResetRequested(phone: phone));
      return;
    }
    bloc.add(AuthPasswordResetConfirmed(
      phone: phone,
      code: _codeController.text.trim(),
      newPassword: _passwordController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.otpSent) {
          setState(() => _codeSent = true);
        } else if (state.status == AuthStatus.unauthenticated && _codeSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password updated')),
          );
          context.go('/login');
        } else if (state.status == AuthStatus.error && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) {
        final loading = state.status == AuthStatus.loading;
        return Scaffold(
          appBar: AppBar(title: const Text('Reset password')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _codeSent ? 'Enter verification code' : 'Find account',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _codeSent
                          ? 'Use the code sent to your phone and choose a new password.'
                          : 'We will send a verification code to your phone.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    AuthTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: '+84 901 234 567',
                      prefixIcon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        final phone = value?.trim() ?? '';
                        if (phone.isEmpty) return 'Phone required';
                        if (!RegExp(r'^\+?[1-9]\d{7,14}$').hasMatch(phone)) {
                          return 'Invalid phone number';
                        }
                        return null;
                      },
                    ),
                    if (_codeSent) ...[
                      const SizedBox(height: 14),
                      AuthTextField(
                        controller: _codeController,
                        label: 'Verification Code',
                        prefixIcon: Icons.pin_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) => (value?.trim().isEmpty ?? true)
                            ? 'Code required'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      AuthTextField(
                        controller: _passwordController,
                        label: 'New Password',
                        prefixIcon: Icons.lock_rounded,
                        obscureText: _obscure,
                        suffix: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password required';
                          }
                          if (value.length < 8) return 'Min 8 characters';
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    GradientButton(
                      label: _codeSent ? 'Update Password' : 'Send Code',
                      icon: _codeSent ? Icons.check_rounded : Icons.sms_rounded,
                      loading: loading,
                      onPressed: loading ? null : _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
