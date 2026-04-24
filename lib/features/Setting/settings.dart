// ignore_for_file: deprecated_member_use

import 'package:btl/features/Users/Cubit/userCubit.dart';
import 'package:btl/app/services/Local/settings_service.dart';
import 'package:btl/features/auth/repository/authRepo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  Future<void> _logout(BuildContext context) async {
    await Authrepo().logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/expenseTracker',
        (route) => false,
      );
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã đăng xuất'),
          backgroundColor: theme.primaryColor,
        ),
      );
      // Clear one-time flag since we've already shown the snackbar here
      await SettingsService.setJustLoggedOut(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildMenuItem(
              icon: Icons.translate,
              title: "Ngôn ngữ",
              iconColor: theme.primaryColor,
              onTap: () {
                Navigator.pushNamed(context, '/languageSelection');
              },
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.people,
              title: "Quản lý danh mục",
              iconColor: Colors.orange,
              onTap: () {
                Navigator.pushNamed(context, '/manageCategory');
              },
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.campaign,
              title: "Giao diện hệ thống",
              iconColor: Colors.red,
              onTap: () {
                Navigator.pushNamed(context, '/interfaceSettings');
              },
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.people_alt,
              title: "Quản lý người dùng",
              iconColor: Colors.green,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/profile',
                  arguments: context.read<UserCubit>().currentUser,
                );
              },
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.account_balance_wallet,
              title: "Tài khoản",
              iconColor: Colors.teal,
              onTap: () {
                Navigator.pushNamed(context, '/manageAccount');
              },
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.notifications,
              title: "Thông báo",
              iconColor: Colors.orange,
              hasNotification: true,
              onTap: () {
                Navigator.pushNamed(context, '/notificationSettings');
              },
            ),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.logout,
              title: "Đăng xuất",
              iconColor: Colors.red,
              onTap: () => _logout(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    bool hasNotification = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
