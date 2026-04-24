// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:developer';

import 'package:btl/core/constants/colors.dart';
import 'package:btl/core/constants/money_source_icons.dart';
import 'package:btl/features/Account/cubit/manageMoneyCubit.dart';
import 'package:btl/features/Account/cubit/manageMoneyState.dart';
import 'package:btl/features/Account/models/money_source.dart';
import 'package:btl/features/transactions/Cubit/transactionCubit.dart';
import 'package:btl/features/transactions/Cubit/transctionState.dart';
import 'package:btl/features/transactions/models/transactionsModels.dart';
// import 'package:btl/shared/utils/localText.dart';
import 'package:btl/shared/utils/mappingIcon.dart';
import 'package:btl/shared/utils/money_source_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  String _formatAmount(num amount) {
    if (amount % 1 == 0) {
      // Là số nguyên
      return amount.toInt().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
      );
    } else {
      // Có phần thập phân
      return amount
          .toStringAsFixed(2)
          .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
    }
  }

  List<Transactionsmodels> transactionsList(
    Map<DateTime, List<Transactionsmodels>> transactionsByDate,
  ) {
    List<Transactionsmodels> allTransactions = [];
    transactionsByDate.forEach((date, transactions) {
      allTransactions.addAll(transactions);
    });
    return allTransactions;
  }

  String? currentAccountId;

  void changeAccount(String? newId) {
    if (newId != null) {
      context.read<TransactionCubit>().fetchTransactionsByAccount(newId);
      context.read<ManageMoneyCubit>().setCurrentAccountName(newId);
      setState(() {
        currentAccountId = newId;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Load accounts first, then fetch transactions after accounts are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ManageMoneyCubit>().getAllAccount();

      // After accounts are loaded, get the current account and fetch transactions
      final manageMoneyCubit = context.read<ManageMoneyCubit>();
      final listAccounts = manageMoneyCubit.listAccounts ?? [];

      if (listAccounts.isNotEmpty) {
        // Nếu đã có currentAccountName (tên), tìm id tương ứng
        final currentName = manageMoneyCubit.currentAccountName;
        final found = listAccounts.firstWhere(
          (acc) => acc.name == currentName,
          orElse: () => listAccounts.first,
        );
        setState(() {
          currentAccountId = found.id;
        });

        // Cập nhật TransactionCubit với id tài khoản hiện tại
        if (currentAccountId != null) {
          context.read<TransactionCubit>().fetchTransactionsByAccount(
            currentAccountId!,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Chưa có tài khoản nào'),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<TransactionCubit, TransactionState>(
      listener: (context, state) {
        if (state.status == TransactionStateStatus.success) {
          context.read<ManageMoneyCubit>().getAllAccount();
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            // Balance Card - Redesigned with colorful gradient
            BalanceCard(
              changeAccount: changeAccount,
              currentAccountId: currentAccountId,
            ),
            // Transaction List
            Expanded(
              child: BlocBuilder<TransactionCubit, TransactionState>(
                builder: (context, state) {
                  if (state.status == TransactionStateStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state.status == TransactionStateStatus.error) {
                    return const Center(child: Text('Lỗi khi tải giao dịch'));
                  }
                  if (state.transactionsList.isEmpty) {
                    return Center(
                      child: Text(
                        'Không có giao dịch nào',
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }
                  final transactionsList = this.transactionsList(
                    state.transactionsList,
                  );
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: transactionsList.length,
                    itemBuilder: (context, index) {
                      final Transactionsmodels transaction =
                          transactionsList[index];
                      final isIncome =
                          transaction.type == TransactionType.income;
                      final amountStr = _formatAmount(transaction.amount);
                      
                      final categoryData = IconMapping.getCategoryByName(
                        transaction.categoriesId,
                      );
                      final iconData = IconMapping.stringToIcon(
                        categoryData?.icon ?? 'Home',
                      );
                      final iconColor = Color(
                        int.parse(categoryData?.color ?? '0xFF2196F3'),
                      );
                      final title = categoryData?.name ?? 'Chưa xác định';
                      return _buildTransactionItem(
                        context,
                        icon: iconData,
                        iconColor: iconColor,
                        title: title,
                        subtitle: transaction.note ?? '',
                        amount: '${isIncome ? '+ ' : '- '}$amountStr VND',
                        isPositive: isIncome,
                        transaction: transaction,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    bool isPositive = false,
    required Transactionsmodels transaction,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(
          context,
          '/add',
          arguments: {'transaction': transaction, 'fromScreen': 'wallet'},
        );
        // Refresh transactions for the current account after returning
        final String? accountIdToRefresh =
            currentAccountId ??
            context.read<ManageMoneyCubit>().listAccounts?.first.id;
        if (accountIdToRefresh != null && accountIdToRefresh.isNotEmpty) {
          context.read<TransactionCubit>().fetchTransactionsByAccount(
            accountIdToRefresh,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color:
                        isPositive
                            ? AppColors.green
                            : AppColors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ví của tôi',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.changeAccount,
    required this.currentAccountId,
  });
  final Function(String?) changeAccount;
  final String? currentAccountId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ManageMoneyCubit, ManageMoneyState>(
      builder: (context, state) {
        final cubit = context.read<ManageMoneyCubit>();
        String currentAccountName = cubit.currentAccountName ?? '';
        
        List<MoneySource> listAccounts =
            state.listAccounts ?? cubit.listAccounts ?? [];

        MoneySource? currentAccount;
        if (listAccounts.isNotEmpty) {
          if (currentAccountId != null) {
            currentAccount = listAccounts.firstWhere(
              (acc) => acc.id == currentAccountId,
              orElse: () => listAccounts.first,
            );
          } else {
            currentAccount = listAccounts.first;
          }
          currentAccountName = currentAccount.name;
        }

        // Lấy tổng thu nhập và chi tiêu theo tài khoản hiện tại
        double totalIncome = 0;
        double totalExpense = 0;
        
        final transactionState = context.watch<TransactionCubit>().state;
        final allTransactions =
            transactionState.transactionsList.values.expand((e) => e).toList();
        final filteredTransactions =
            currentAccountId == null
                ? allTransactions
                : allTransactions
                    .where((t) => t.accountId == currentAccountId)
                    .toList();
        for (final tx in filteredTransactions) {
          if (tx.type == TransactionType.income) {
            totalIncome += tx.amount;
          } else if (tx.type == TransactionType.expense) {
            totalExpense += tx.amount;
          }
        }

        final Color fallbackColor = theme.primaryColor;
        final Color onBrand = Colors.white;

        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: fallbackColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tài khoản của tôi',
                          style: TextStyle(color: onBrand.withOpacity(0.8), fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentAccountName.isNotEmpty ? currentAccountName : '---',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: onBrand,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: currentAccountId ?? (listAccounts.isNotEmpty ? listAccounts.first.id : null),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                        dropdownColor: theme.cardColor,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        items: listAccounts.map((e) => DropdownMenuItem(
                          value: e.id,
                          child: Text(e.name, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                        )).toList(),
                        onChanged: changeAccount,
                        selectedItemBuilder: (context) => listAccounts.map((e) => Center(child: Text(e.name, style: const TextStyle(color: Colors.white)))).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildBalanceInfo('Thu nhập', totalIncome, AppColors.green, Colors.white),
                  const SizedBox(width: 12),
                  _buildBalanceInfo('Chi tiêu', totalExpense, AppColors.red, Colors.white),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalanceInfo(String label, double amount, Color iconColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              '${amount.toStringAsFixed(0)} ₫',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
