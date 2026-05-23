import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/info_chip.dart';
import '../../../auth/data/models/auth_models.dart';
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
        final name = _displayName(user);
        final role = (user?.role ?? 'customer').toUpperCase();
        final status = (user?.status ?? 'active').toUpperCase();
        final phoneLabel = user != null && user.phone.isNotEmpty ? user.phone : 'Add phone number';

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              _ProfileHero(user: user, name: name, role: role, status: status),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _OverviewCard(email: user?.email ?? 'No email linked', phone: phoneLabel, verified: user?.phoneVerified ?? false),
                    const SizedBox(height: 20),
                    const _SectionHeader(
                      title: 'Account',
                      subtitle: 'Personal identity, payment access, and security controls.',
                    ),
                    const SizedBox(height: 12),
                    _SettingsGroup(
                      items: [
                        _SettingItem(
                          icon: Icons.person_rounded,
                          iconColor: AppColors.primary,
                          title: 'Edit profile',
                          subtitle: 'Name and contact details used across the app',
                          badge: 'PERSONAL',
                          onTap: () => context.push('/profile/edit'),
                        ),
                        _SettingItem(
                          icon: Icons.account_balance_wallet_rounded,
                          iconColor: AppColors.success,
                          title: 'Crab Wallet',
                          subtitle: 'Balance, transfer, and payment activity',
                          badge: 'PAY',
                          onTap: () => context.push('/wallet'),
                        ),
                        _SettingItem(
                          icon: Icons.shield_rounded,
                          iconColor: AppColors.info,
                          title: 'Security',
                          subtitle: 'Password, verification, and account protection',
                          badge: user?.phoneVerified == true ? 'VERIFIED' : 'REVIEW',
                          onTap: () => context.push('/profile/security'),
                        ),
                        _SettingItem(
                          icon: Icons.location_on_rounded,
                          iconColor: AppColors.warning,
                          title: 'Saved addresses',
                          subtitle: 'Home, office, and pickup shortcuts',
                          badge: 'RIDE',
                          onTap: () => context.push('/profile/addresses'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _SectionHeader(
                      title: 'Preferences',
                      subtitle: 'How Crab looks and communicates on your device.',
                    ),
                    const SizedBox(height: 12),
                    _SettingsGroup(
                      items: [
                        _SettingItem(
                          icon: Icons.notifications_rounded,
                          iconColor: AppColors.accent,
                          title: 'Notifications',
                          subtitle: 'Order updates, promotions, and system messages',
                          badge: 'LIVE',
                          onTap: () => context.push('/notifications'),
                        ),
                        _SettingItem(
                          icon: Icons.dark_mode_rounded,
                          iconColor: AppColors.textPrimaryLight,
                          title: 'Appearance',
                          subtitle: 'Follow the system light and dark theme',
                          badge: 'SYSTEM',
                          onTap: () => _showInfo(
                            context,
                            title: 'Appearance',
                            message: 'Crab automatically follows the light or dark theme from your device.',
                          ),
                        ),
                        _SettingItem(
                          icon: Icons.language_rounded,
                          iconColor: AppColors.info,
                          title: 'Language',
                          subtitle: 'Vietnamese based on your device settings',
                          badge: 'VI',
                          onTap: () => _showInfo(
                            context,
                            title: 'Language',
                            message: 'Crab currently follows your device language settings.',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _SectionHeader(
                      title: 'Support',
                      subtitle: 'Help, privacy, and app information.',
                    ),
                    const SizedBox(height: 12),
                    _SettingsGroup(
                      items: [
                        _SettingItem(
                          icon: Icons.help_outline_rounded,
                          iconColor: AppColors.primary,
                          title: 'Help center',
                          subtitle: 'Answers for rides, food, and payments',
                          onTap: () => _showInfo(
                            context,
                            title: 'Help center',
                            message: 'Open a ride or food order to contact support directly from the related journey.',
                          ),
                        ),
                        _SettingItem(
                          icon: Icons.privacy_tip_rounded,
                          iconColor: AppColors.warning,
                          title: 'Privacy policy',
                          subtitle: 'How Crab stores and protects your data',
                          onTap: () => _showInfo(
                            context,
                            title: 'Privacy policy',
                            message: 'Crab protects personal information according to the current privacy policy.',
                          ),
                        ),
                        _SettingItem(
                          icon: Icons.info_outline_rounded,
                          iconColor: AppColors.info,
                          title: 'About Crab',
                          subtitle: 'Version 1.0.0',
                          badge: 'v1.0.0',
                          onTap: () => _showInfo(context, title: 'About Crab', message: 'Crab Super App 1.0.0'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _LogoutCard(
                      onTap: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInfo(BuildContext context, {required String title, required String message}) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  String _displayName(UserModel? user) {
    if (user == null) return 'Người dùng';
    final name = user.fullName.trim();
    return name.isEmpty ? 'Người dùng' : name;
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.user, required this.name, required this.role, required this.status});

  final UserModel? user;
  final String name;
  final String role;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.primary),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Avatar(url: user?.avatarUrl),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'No email linked',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.84), fontSize: 12, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    InfoChip(label: role, icon: Icons.badge_rounded, dense: true),
                    InfoChip(
                      label: user?.phoneVerified == true ? 'Verified' : 'Needs review',
                      icon: user?.phoneVerified == true ? Icons.verified_rounded : Icons.warning_amber_rounded,
                      variant: user?.phoneVerified == true ? InfoChipVariant.success : InfoChipVariant.warning,
                      dense: true,
                    ),
                    InfoChip(label: status, icon: Icons.circle, dense: true),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _HeroAction(
                        label: 'Edit profile',
                        filled: true,
                        onTap: () => context.push('/profile/edit'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HeroAction(
                        label: 'Security',
                        onTap: () => context.push('/profile/security'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.email, required this.phone, required this.verified});

  final String email;
  final String phone;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
        boxShadow: AppShadows.shadowSoft,
      ),
      child: Column(
        children: [
          _OverviewRow(icon: Icons.mail_outline_rounded, label: 'Email', value: email),
          const SizedBox(height: 14),
          _OverviewRow(icon: Icons.phone_rounded, label: 'Phone', value: phone),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text('Verification', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              InfoChip(
                label: verified ? 'Protected' : 'Review account',
                icon: verified ? Icons.shield_rounded : Icons.warning_amber_rounded,
                variant: verified ? InfoChipVariant.success : InfoChipVariant.warning,
                dense: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimaryLight)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 12, height: 1.45, color: AppColors.textSecondaryLight)),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.items});

  final List<_SettingItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
        boxShadow: AppShadows.shadowSoft,
      ),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            items[index],
            if (index != items.length - 1)
              const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.borderLight),
          ],
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.textSecondaryLight)),
                  ],
                ),
              ),
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.4, color: iconColor),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(Icons.chevron_right_rounded, size: 22, color: AppColors.textSecondaryLight),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutCard extends StatelessWidget {
  const _LogoutCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.16)),
            boxShadow: AppShadows.shadowSoft,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Logout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.error)),
                    SizedBox(height: 3),
                    Text('Sign out from the current account safely.', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 22, color: AppColors.error),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  const _HeroAction({required this.label, required this.onTap, this.filled = false});

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 44,
          decoration: BoxDecoration(
            color: filled ? Colors.white : Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: filled ? 0 : 0.20)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: filled ? AppColors.primary : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final hasImage = url != null && url!.isNotEmpty;
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: AppShadows.shadowElevated,
      ),
      child: CircleAvatar(
        radius: 32,
        backgroundColor: Colors.white,
        backgroundImage: hasImage ? NetworkImage(url!) : null,
        child: hasImage
            ? null
            : const Icon(Icons.person, color: AppColors.primary, size: 34),
      ),
    );
  }
}
