// ignore_for_file: file_names

import 'package:financy_ui/features/Account/cubit/manageMoneyCubit.dart';
import 'package:financy_ui/features/transactions/view/add.dart';
import 'package:financy_ui/features/Users/Cubit/userCubit.dart';
import 'package:financy_ui/features/transactions/view/home.dart';
import 'package:financy_ui/features/notification/cubit/notificationCubit.dart';
import 'package:financy_ui/features/Setting/settings.dart';
import 'package:financy_ui/features/transactions/view/statiscal.dart';
import 'package:financy_ui/features/transactions/view/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:financy_ui/l10n/app_localizations.dart';
import 'package:financy_ui/features/auth/cubits/authCubit.dart';
import 'package:financy_ui/features/auth/cubits/authState.dart';

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
      MaterialPageRoute(builder: (_) => AddTransactionScreen()),
    );
  }

  final List<Widget> _pages = [Home(), Wallet(), Statiscal(), Settings()];

  @override
  void initState() {
    context.read<UserCubit>().getUser();
    context.read<ManageMoneyCubit>().getAllAccount();
    context.read<NotificationCubit>().loadNotificationSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocal = AppLocalizations.of(context);
    return BlocListener<Authcubit, Authstate>(
      listener: (context, state) {
        if (state.authStatus == AuthStatus.error ||
            state.authStatus == AuthStatus.unAuthenticated) {
          Navigator.pushNamed(context, '/login');
        }
      },
      child: Scaffold(
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
                label: appLocal?.transactionBook ?? 'Transactions',
                theme: theme,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.wallet,
                label: appLocal?.wallet ?? 'Wallet',
                theme: theme,
              ),
              const SizedBox(width: 56), // space for FAB
              _buildNavItem(
                index: 2,
                icon: Icons.pie_chart,
                label: appLocal?.statistics ?? 'Statistics',
                theme: theme,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.settings,
                label: appLocal?.settings ?? 'Settings',
                theme: theme,
              ),
            ],
          ),
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
        ? theme.bottomNavigationBarTheme.selectedItemColor
        : theme.bottomNavigationBarTheme.unselectedItemColor;

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
