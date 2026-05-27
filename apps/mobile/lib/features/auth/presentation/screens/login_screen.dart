import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _usePhone = true;
  bool _obscure = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final bloc = context.read<AuthBloc>();
    if (_usePhone) {
      bloc.add(AuthPhoneLoginRequested(phone: _phoneController.text.trim()));
    } else {
      bloc.add(
        AuthEmailLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go('/home');
        } else if (state.status == AuthStatus.otpSent &&
            state.pendingPhone != null) {
          context.push('/otp?phone=${state.pendingPhone}');
        } else if (state.status == AuthStatus.error && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: cs.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md)),
            ),
          );
        }
      },
      builder: (context, state) {
        final loading = state.status == AuthStatus.loading;
        return Scaffold(
          body: Stack(
            children: [
              Container(
                  decoration:
                      const BoxDecoration(gradient: AppGradients.primary)),
              Positioned(
                top: -30,
                right: -18,
                child: Container(
                  width: 152,
                  height: 152,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md,
                      AppSpacing.lg, AppSpacing.md, AppSpacing.xl),
                  child: AutofillGroup(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(AppRadii.xl),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.14)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: AppShadows.shadowElevated,
                                  ),
                                  child: const Icon(
                                    Icons.local_taxi_rounded,
                                    size: 38,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Text(
                                  'Welcome back',
                                  style:
                                      theme.textTheme.displayMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Đăng nhập để đặt xe, gọi món và quản lý CrabPay trong một trải nghiệm rõ ràng, an toàn.',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    height: 1.42,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                const Wrap(
                                  spacing: AppSpacing.xs,
                                  runSpacing: AppSpacing.xs,
                                  children: [
                                    _HeroChip(
                                        icon: Icons.sms_rounded,
                                        label: 'OTP nhanh'),
                                    _HeroChip(
                                        icon: Icons.shield_outlined,
                                        label: 'Bảo mật'),
                                    _HeroChip(
                                        icon: Icons.local_offer_rounded,
                                        label: 'Ưu đãi mỗi ngày'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: cs.surface,
                              borderRadius: BorderRadius.circular(AppRadii.xl),
                              border: Border.all(
                                  color:
                                      cs.outlineVariant.withValues(alpha: 0.8)),
                              boxShadow: AppShadows.shadowElevated,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Sign in',
                                  style: theme.textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Chọn cách đăng nhập phù hợp nhất với bạn.',
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(color: cs.onSurfaceVariant),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                _MethodToggle(
                                  usePhone: _usePhone,
                                  onChange: (value) =>
                                      setState(() => _usePhone = value),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                AnimatedSwitcher(
                                  duration: AppMotion.normal,
                                  switchInCurve: AppMotion.standard,
                                  child: _usePhone
                                      ? _phoneFields()
                                      : _emailFields(),
                                ),
                                if (!_usePhone)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () =>
                                          context.push('/forgot-password'),
                                      child: const Text('Forgot password?'),
                                    ),
                                  ),
                                const SizedBox(height: AppSpacing.md),
                                GradientButton(
                                  label: _usePhone ? 'Send OTP' : 'Sign In',
                                  icon: _usePhone
                                      ? Icons.sms_rounded
                                      : Icons.lock_open_rounded,
                                  height: 60,
                                  borderRadius: AppRadii.lg,
                                  onPressed: loading ? null : _submit,
                                  loading: loading,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  _usePhone
                                      ? 'Mã OTP chỉ dùng một lần và giúp bảo vệ tài khoản Crab của bạn.'
                                      : 'Một tài khoản dùng xuyên suốt cho đi xe, đồ ăn và ví CrabPay.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: cs.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.92),
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.push('/register'),
                                child: Text(
                                  'Sign Up',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _phoneFields() {
    return Column(
      key: const ValueKey('phone'),
      children: [
        AuthTextField(
          controller: _phoneController,
          label: 'Phone number',
          hint: 'Số điện thoại demo',
          prefixIcon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          autofillHints: const [AutofillHints.telephoneNumber],
          validator: (value) {
            final phone = value?.trim() ?? '';
            if (phone.isEmpty) return 'Phone required';
            if (!RegExp(r'^\+?[1-9]\d{7,14}$').hasMatch(phone)) {
              return 'Invalid phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _emailFields() {
    return Column(
      key: const ValueKey('email'),
      children: [
        AuthTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'you@example.com',
          prefixIcon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username, AutofillHints.email],
          validator: (value) {
            final email = value?.trim() ?? '';
            if (email.isEmpty) return 'Email required';
            if (!email.contains('@')) return 'Invalid email';
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        AuthTextField(
          controller: _passwordController,
          label: 'Password',
          prefixIcon: Icons.lock_rounded,
          obscureText: _obscure,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          autofillHints: const [AutofillHints.password],
          suffix: IconButton(
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: Icon(_obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Password required';
            if (value.length < 8) return 'Min 8 characters';
            return null;
          },
        ),
      ],
    );
  }
}

class _MethodToggle extends StatelessWidget {
  const _MethodToggle({required this.usePhone, required this.onChange});

  final bool usePhone;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 50,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color:
            cs.surfaceContainerHighest.withValues(alpha: isDark ? 0.4 : 0.66),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        children: [
          _MethodTogglePill(
            label: 'Phone',
            icon: Icons.phone_rounded,
            active: usePhone,
            onTap: () => onChange(true),
          ),
          const SizedBox(width: AppSpacing.xs),
          _MethodTogglePill(
            label: 'Email',
            icon: Icons.email_rounded,
            active: !usePhone,
            onTap: () => onChange(false),
          ),
        ],
      ),
    );
  }
}

class _MethodTogglePill extends StatelessWidget {
  const _MethodTogglePill({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: Ink(
            decoration: BoxDecoration(
              color: active ? cs.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(
                color: active
                    ? cs.primary.withValues(alpha: 0.16)
                    : Colors.transparent,
              ),
              boxShadow: active ? AppShadows.shadowSoft : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 18, color: active ? cs.primary : cs.onSurfaceVariant),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: active ? cs.primary : cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
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

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
