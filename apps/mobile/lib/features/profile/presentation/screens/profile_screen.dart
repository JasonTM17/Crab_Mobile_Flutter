import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
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
        final name = user?.fullName.trim().isNotEmpty == true
            ? user!.fullName
            : 'Người dùng';
        final role = (user?.role ?? 'customer').toUpperCase();

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                stretch: true,
                backgroundColor: AppColors.primary,
                surfaceTintColor: AppColors.primary,
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: _ProfileHeader(name: name, role: role),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SectionTitle('Tài khoản'),
                      _SettingsGroup(
                        items: [
                          _SettingItem(
                            icon: Icons.account_balance_wallet_rounded,
                            iconColor: AppColors.primary,
                            title: 'Ví Crab',
                            subtitle: 'Quản lý số dư & phương thức',
                            onTap: () => context.push('/wallet'),
                          ),
                          _SettingItem(
                            icon: Icons.location_on_rounded,
                            iconColor: AppColors.info,
                            title: 'Địa chỉ đã lưu',
                            subtitle: 'Nhà, công ty và các điểm khác',
                            onTap: () => context.push('/profile/addresses'),
                          ),
                          _SettingItem(
                            icon: Icons.directions_car_rounded,
                            iconColor: AppColors.warning,
                            title: 'Phương tiện',
                            subtitle: 'Loại xe ưu tiên khi đặt',
                            onTap: () => _showInfo(
                              context,
                              title: 'Phương tiện',
                              message:
                                  'Bạn có thể chọn lại loại xe trên màn đặt chuyến.',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const _SectionTitle('Cài đặt'),
                      _SettingsGroup(
                        items: [
                          _SettingItem(
                            icon: Icons.dark_mode_rounded,
                            iconColor: AppColors.textPrimaryLight,
                            title: 'Giao diện',
                            subtitle: 'Theo hệ thống',
                            onTap: () => _showInfo(
                              context,
                              title: 'Giao diện',
                              message:
                                  'Crab tự đổi theo chế độ sáng tối của thiết bị.',
                            ),
                          ),
                          _SettingItem(
                            icon: Icons.language_rounded,
                            iconColor: AppColors.info,
                            title: 'Ngôn ngữ',
                            subtitle: 'Tiếng Việt',
                            onTap: () => _showInfo(
                              context,
                              title: 'Ngôn ngữ',
                              message:
                                  'Crab hiện theo ngôn ngữ thiết bị của bạn.',
                            ),
                          ),
                          _SettingItem(
                            icon: Icons.notifications_rounded,
                            iconColor: AppColors.accent,
                            title: 'Thông báo',
                            subtitle: 'Đơn hàng, ưu đãi và tin nhắn',
                            onTap: () => context.push('/notifications'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const _SectionTitle('Hỗ trợ'),
                      _SettingsGroup(
                        items: [
                          _SettingItem(
                            icon: Icons.help_outline_rounded,
                            iconColor: AppColors.primary,
                            title: 'Trung tâm trợ giúp',
                            subtitle: 'Câu hỏi thường gặp',
                            onTap: () => _showInfo(
                              context,
                              title: 'Trung tâm trợ giúp',
                              message:
                                  'Mở chuyến đi hoặc đơn hàng để liên hệ hỗ trợ trực tiếp.',
                            ),
                          ),
                          _SettingItem(
                            icon: Icons.info_outline_rounded,
                            iconColor: AppColors.info,
                            title: 'Về Crab',
                            subtitle: 'Phiên bản 1.0.0',
                            onTap: () => _showInfo(
                              context,
                              title: 'Về Crab',
                              message: 'Crab Super App 1.0.0',
                            ),
                          ),
                          _SettingItem(
                            icon: Icons.privacy_tip_rounded,
                            iconColor: AppColors.warning,
                            title: 'Chính sách bảo mật',
                            subtitle: 'Cách Crab xử lý dữ liệu của bạn',
                            onTap: () => _showInfo(
                              context,
                              title: 'Chính sách bảo mật',
                              message:
                                  'Crab cam kết bảo vệ dữ liệu cá nhân theo quy định.',
                            ),
                          ),
                          _SettingItem(
                            icon: Icons.logout_rounded,
                            iconColor: AppColors.error,
                            title: 'Đăng xuất',
                            subtitle: 'Thoát khỏi tài khoản hiện tại',
                            danger: true,
                            onTap: () => context
                                .read<AuthBloc>()
                                .add(const AuthLogoutRequested()),
                          ),
                        ],
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

  void _showInfo(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String role;

  const _ProfileHeader({required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_rounded,
                    size: 44,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      role,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Text(
                      'Sửa hồ sơ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondaryLight,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<_SettingItem> items;
  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            items[i],
            if (i != items.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 1,
                  color: AppColors.borderLight.withValues(alpha: 0.6),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  const _SettingItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor =
        danger ? AppColors.error : AppColors.textPrimaryLight;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }
}
