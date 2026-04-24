// ignore_for_file: file_names

import 'package:btl/features/Account/cubit/manageMoneyCubit.dart';
import 'package:btl/features/transactions/view/add.dart';
import 'package:btl/features/Users/Cubit/userCubit.dart';
import 'package:btl/features/transactions/view/home.dart';
import 'package:btl/features/notification/cubit/notificationCubit.dart';
import 'package:btl/features/Setting/settings.dart';
import 'package:btl/features/transactions/view/statiscal.dart';
import 'package:btl/features/transactions/view/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Lưu ý: Nếu bạn chưa có đa ngôn ngữ, hãy comment hoặc tạo file l10n
// import 'package:btl/l10n/app_localizations.dart';

// Tạm thời comment nếu chưa có feature auth
// import 'package:btl/features/auth/cubits/authCubit.dart';
// import 'package:btl/features/auth/cubits/authState.dart';

class ExpenseTrackerScreen extends StatefulWidget {
  const ExpenseTrackerScreen({super.key});

  @override
  State<ExpenseTrackerScreen> createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openAddTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
  }

  final List<Widget> _pages = [
    const Home(),
    const Wallet(),
    const Statiscal(),
    const Settings()
  ];

  @override
  void initState() {
    super.initState();
    // Đảm bảo các Cubit đã được cung cấp ở cấp trên (trong main.dart)
    context.read<UserCubit>().getUser();
    context.read<ManageMoneyCubit>().getAllAccount();
    context.read<NotificationCubit>().loadNotificationSettings();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(child: _pages[_currentIndex]),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTransaction,
        backgroundColor: theme.colorScheme.primary,
        child: Icon(
          Icons.add,
          color: theme.colorScheme.onPrimary,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: theme.bottomNavigationBarTheme.backgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.timeline,
              label: 'Giao dịch',
              theme: theme,
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.wallet,
              label: 'Ví',
              theme: theme,
            ),
            const SizedBox(width: 56), // khoảng trống cho FAB
            _buildNavItem(
              index: 2,
              icon: Icons.pie_chart,
              label: 'Thống kê',
              theme: theme,
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.settings,
              label: 'Cài đặt',
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required ThemeData theme,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.hintColor;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
