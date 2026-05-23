import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _seconds = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes.first.requestFocus();
    });
  }

  void _startTimer() {
    _seconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((controller) => controller.text).join();

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_code.length == 6) _verify();
  }

  void _verify() {
    if (_code.length != 6) return;
    context
        .read<AuthBloc>()
        .add(AuthOtpVerifyRequested(phone: widget.phone, code: _code));
  }

  void _resend() {
    if (_seconds > 0) return;
    context.read<AuthBloc>().add(AuthPhoneLoginRequested(phone: widget.phone));
    _startTimer();
  }

  String _maskedPhone() {
    final phone = widget.phone;
    if (phone.length < 4) return phone;
    return '${phone.substring(0, phone.length - 4).replaceAll(RegExp(r'\d'), '•')}${phone.substring(phone.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go('/home');
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
          for (final controller in _controllers) {
            controller.clear();
          }
          _focusNodes.first.requestFocus();
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
                top: -28,
                right: -14,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md,
                      AppSpacing.sm, AppSpacing.md, AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Material(
                          color: Colors.white.withValues(alpha: 0.16),
                          shape: const CircleBorder(),
                          child: IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white),
                            tooltip: 'Quay lại',
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: AppShadows.shadowSoft,
                              ),
                              child: const Icon(Icons.sms_outlined,
                                  color: AppColors.primary, size: 30),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Verify your phone',
                              style: theme.textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Enter the 6-digit code sent to ${_maskedPhone()} to unlock your Crab account.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.92),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(AppSpacing.lg,
                              AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(6, _otpBox),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              GradientButton(
                                label: 'Verify',
                                icon: Icons.check_circle_rounded,
                                height: 60,
                                borderRadius: AppRadii.lg,
                                onPressed: loading || _code.length != 6
                                    ? null
                                    : _verify,
                                loading: loading,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _ResendRow(
                                  seconds: _seconds,
                                  onResend: _resend,
                                  accent: cs.primary),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.md),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded,
                                        size: 18, color: cs.primary),
                                    const SizedBox(width: AppSpacing.xs),
                                    Expanded(
                                      child: Text(
                                        'Keep this screen open to auto-fill the code from SMS.',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                                color: cs.onSurfaceVariant,
                                                height: 1.35),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _otpBox(int index) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final filled = _controllers[index].text.isNotEmpty;
    final focused = _focusNodes[index].hasFocus;

    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.emphasis,
      width: 48,
      height: 60,
      decoration: BoxDecoration(
        color: filled
            ? cs.primary.withValues(alpha: 0.1)
            : cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: focused || filled
              ? cs.primary
              : cs.outlineVariant.withValues(alpha: 0.84),
          width: focused || filled ? 1.5 : 1,
        ),
        boxShadow:
            focused ? AppShadows.coloredGlow(cs.primary, opacity: 0.14) : null,
      ),
      alignment: Alignment.center,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: theme.textTheme.headlineMedium
            ?.copyWith(fontWeight: FontWeight.w800),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          setState(() {});
          _onChanged(index, value);
        },
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow({
    required this.seconds,
    required this.onResend,
    required this.accent,
  });

  final int seconds;
  final VoidCallback onResend;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Didn't receive the code? ", style: theme.textTheme.bodyMedium),
        if (seconds > 0)
          Text(
            'Resend in ${seconds}s',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          )
        else
          TextButton(
            onPressed: onResend,
            child: Text(
              'Resend',
              style: TextStyle(color: accent, fontWeight: FontWeight.w800),
            ),
          ),
      ],
    );
  }
}
