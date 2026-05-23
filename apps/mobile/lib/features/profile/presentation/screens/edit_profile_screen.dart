import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/info_chip.dart';
import '../../data/models/user_profile_model.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _synced = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadProfile());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _sync(ProfileState state) {
    if (_synced) return;
    if (state case ProfileLoaded(:final profile) || ProfileUpdated(:final profile)) {
      _nameController.text = profile.fullName ?? '';
      _phoneController.text = profile.phone ?? '';
      _synced = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        _sync(state);
        if (state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated')),
          );
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        _sync(state);
        final loading = state is ProfileLoading;
        final profile = switch (state) {
          ProfileLoaded(:final profile) => profile,
          ProfileUpdated(:final profile) => profile,
          _ => null,
        };

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundLight,
            scrolledUnderElevation: 0,
            title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (profile != null) ...[
                _ProfileIdentityCard(profile: profile),
                const SizedBox(height: 20),
              ],
              const _SectionHeader(
                title: 'Personal details',
                subtitle: 'These details appear across wallet, rides, and orders.',
              ),
              const SizedBox(height: 12),
              _FieldCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone number',
                        prefixIcon: Icon(Icons.phone_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GradientButton(
                label: 'Save changes',
                icon: Icons.check_rounded,
                loading: loading,
                onPressed: loading
                    ? null
                    : () => context.read<ProfileBloc>().add(
                          UpdateProfile(
                            fullName: _nameController.text.trim(),
                            phone: _phoneController.text.trim(),
                          ),
                        ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Changes are applied to your account immediately after saving.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, height: 1.45, color: AppColors.textSecondaryLight),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileIdentityCard extends StatelessWidget {
  const _ProfileIdentityCard({required this.profile});

  final UserProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppGradients.walletHero,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.coloredGlow(AppColors.primary, opacity: 0.24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white,
                child: Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (profile.fullName?.trim().isNotEmpty ?? false) ? profile.fullName!.trim() : 'Account owner',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.82), fontSize: 12),
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
              InfoChip(label: profile.role.toUpperCase(), icon: Icons.badge_rounded, dense: true),
              InfoChip(
                label: profile.isVerified ? 'Phone verified' : 'Verification needed',
                icon: profile.isVerified ? Icons.verified_rounded : Icons.warning_amber_rounded,
                variant: profile.isVerified ? InfoChipVariant.success : InfoChipVariant.warning,
                dense: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
        boxShadow: AppShadows.shadowSoft,
      ),
      child: child,
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
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 12, height: 1.45, color: AppColors.textSecondaryLight)),
      ],
    );
  }
}
