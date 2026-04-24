// ignore_for_file: deprecated_member_use, avoid_print, unrelated_type_equality_checks

import 'dart:developer';
import 'dart:io';

import 'package:btl/features/transactions/Cubit/transactionCubit.dart';
import 'package:btl/features/Users/Cubit/userCubit.dart';
import 'package:btl/features/Users/Cubit/userState.dart';
import 'package:btl/features/Account/cubit/manageMoneyCubit.dart';
import 'package:btl/features/Users/models/userModels.dart';
import 'package:btl/features/transactions/Cubit/transctionState.dart';
import 'package:btl/features/transactions/models/transactionsModels.dart';
import 'package:btl/features/Account/models/money_source.dart';
import 'package:btl/app/services/Local/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:btl/core/constants/colors.dart';
import 'package:btl/shared/utils/color_utils.dart';
import 'package:btl/shared/utils/mappingIcon.dart';
// import 'package:btl/l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    print(Hive.box('settings').toMap());
    context.read<TransactionCubit>().fetchTransactionsByDate();
    super.initState();
  }

  // Calculate monthly data for chart (full 12 months)
  Map<int, Map<String, double>> _calculateMonthlyData(
    Map<DateTime, List<Transactionsmodels>> transactions,
  ) {
    final monthlyData = <int, Map<String, double>>{};
    final currentYear = DateTime.now().year;

    // Initialize 12 months data
    for (int month = 1; month <= 12; month++) {
      monthlyData[month] = {'income': 0.0, 'expense': 0.0};
    }

    transactions.forEach((date, txList) {
      if (date.year == currentYear) {
        for (var tx in txList) {
          final month = date.month;
          if (tx.type == TransactionType.income) {
            monthlyData[month]!['income'] =
                (monthlyData[month]!['income']! + tx.amount.toDouble());
          } else if (tx.type == TransactionType.expense) {
            monthlyData[month]!['expense'] =
                (monthlyData[month]!['expense']! + tx.amount.toDouble());
          }
        }
      }
    });

    return monthlyData;
  }

  // Fixed unit conversion to tens of thousands (chục nghìn)
  Map<String, dynamic> _getSmartUnit(double maxAmount) {
    return {'divisor': 10000.0, 'unit': '0K', 'unitName': 'chục nghìn'};
  }

  // Convert amount based on smart unit
  double _convertAmount(double amount, double divisor) {
    return amount / divisor;
  }

  // Get max amount to determine unit
  double _getMaxAmount(Map<int, Map<String, double>> monthlyData) {
    double maxValue = 0;
    for (var data in monthlyData.values) {
      final income = data['income']!;
      final expense = data['expense']!;
      if (income > maxValue) maxValue = income;
      if (expense > maxValue) maxValue = expense;
    }
    return maxValue;
  }

  // Calculate max Y value for chart with smart scaling (in tens of thousands)
  double _getMaxY(Map<int, Map<String, double>> monthlyData, double divisor) {
    double maxValue = 0;
    for (var data in monthlyData.values) {
      final income = _convertAmount(data['income']!, divisor);
      final expense = _convertAmount(data['expense']!, divisor);
      if (income > maxValue) maxValue = income;
      if (expense > maxValue) maxValue = expense;
    }

    if (maxValue == 0) return 10.0;

    double interval;
    if (maxValue <= 5) {
      interval = 1.0;
    } else if (maxValue <= 20) {
      interval = 5.0;
    } else if (maxValue <= 50) {
      interval = 10.0;
    } else {
      interval = 20.0;
    }

    final paddedMax = maxValue * 1.2;
    return ((paddedMax / interval).ceil() * interval).toDouble().clamp(
      interval,
      double.infinity,
    );
  }

  String _formatTooltipAmount(double amount) {
    if (amount >= 1000000000.0) {
      return '${(amount / 1000000000.0).toStringAsFixed(1)} tỷ ₫';
    } else if (amount >= 1000000.0) {
      return '${(amount / 1000000.0).toStringAsFixed(1)} triệu ₫';
    } else if (amount >= 1000.0) {
      return '${(amount / 1000.0).toStringAsFixed(0)} nghìn ₫';
    } else {
      return '${amount.toStringAsFixed(0)} ₫';
    }
  }

  double _calculateChartWidth() {
    const double monthWidth = 60.0;
    const double leftPadding = 60.0;
    const double rightPadding = 20.0;
    return leftPadding + rightPadding + (12 * monthWidth);
  }

  bool _needsScroll(double screenWidth) {
    final chartWidth = _calculateChartWidth();
    return chartWidth > screenWidth - 32;
  }

  void _scrollToCurrentMonth(ScrollController scrollController) {
    if (!scrollController.hasClients) return;
    final currentMonth = DateTime.now().month;
    final screenWidth = MediaQuery.of(context).size.width - 64;
    final monthWidth = 60.0;
    final visibleMonths = (screenWidth / monthWidth).floor().clamp(1, 12);
    final centerOffset = (visibleMonths / 2).floor();
    final chartWidth = _calculateChartWidth();
    final maxScrollOffset = (chartWidth - screenWidth).clamp(0.0, double.infinity);

    if (maxScrollOffset <= 0) return;
    final maxTargetIndex = (12 - visibleMonths).clamp(0, 11);
    final targetIndex = (currentMonth - centerOffset - 1).clamp(0, maxTargetIndex);
    final scrollOffset = (targetIndex * monthWidth).clamp(0.0, maxScrollOffset);

    if (scrollOffset > 0 && scrollOffset.isFinite) {
      scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildScrollableChart(
    List<FlSpot> incomeSpots,
    List<FlSpot> expenseSpots,
    Map<int, Map<String, double>> monthlyData,
    double divisor,
    ThemeData theme,
  ) {
    final ScrollController scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentMonth(scrollController);
    });

    return Stack(
      children: [
        SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: _calculateChartWidth(),
            child: _buildLineChart(
              incomeSpots,
              expenseSpots,
              monthlyData,
              divisor,
              theme,
            ),
          ),
        ),
        Positioned(
          left: 55,
          top: 0,
          bottom: 20,
          child: Container(
            width: 12,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.cardColor, theme.cardColor.withOpacity(0)],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 20,
          child: Container(
            width: 12,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.cardColor.withOpacity(0), theme.cardColor],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () => _scrollToCurrentMonth(scrollController),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.primaryColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.today, size: 12, color: theme.primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    'Tháng này',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart(
    List<FlSpot> incomeSpots,
    List<FlSpot> expenseSpots,
    Map<int, Map<String, double>> monthlyData,
    double divisor,
    ThemeData theme,
  ) {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => theme.colorScheme.surface,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final isIncome = touchedSpot.barIndex == 0;
                final month = touchedSpot.x.toInt();
                final monthNames = ['', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10', 'T11', 'T12'];
                return LineTooltipItem(
                  '${monthNames[month]}\n${isIncome ? 'Thu nhập' : 'Chi tiêu'}: ${_formatTooltipAmount(touchedSpot.y * divisor)}',
                  TextStyle(
                    color: isIncome ? AppColors.green : AppColors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getMaxY(monthlyData, divisor) / 5,
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text('${(value * 10).toInt()}K', style: const TextStyle(fontSize: 10)),
              reservedSize: 40,
              interval: _getMaxY(monthlyData, divisor) / 5,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final months = ['', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10', 'T11', 'T12'];
                if (value >= 1 && value <= 12) return Text(months[value.toInt()], style: const TextStyle(fontSize: 10));
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: incomeSpots,
            isCurved: true,
            color: AppColors.green,
            barWidth: 3,
            belowBarData: BarAreaData(show: true, color: AppColors.green.withOpacity(0.1)),
          ),
          LineChartBarData(
            spots: expenseSpots,
            isCurved: true,
            color: AppColors.red,
            barWidth: 3,
            belowBarData: BarAreaData(show: true, color: AppColors.red.withOpacity(0.1)),
          ),
        ],
        minY: 0,
        maxY: _getMaxY(monthlyData, divisor),
      ),
    );
  }

  String _formatAmount(double amount, {bool isUSD = false}) {
    final formatter = isUSD ? NumberFormat('#,##0.00', 'en_US') : NumberFormat('#,###', 'vi_VN');
    return isUSD ? '\$${formatter.format(amount)}' : '${formatter.format(amount.toInt())} ₫';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        UserModel? user = state.status == UserStatus.success ? state.user : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (SettingsService.isGuestLogin()) {
                        _showLoginPromptDialog(context);
                      } else {
                        Navigator.pushNamed(context, '/profile', arguments: user);
                      }
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      child: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Xin chào,'),
                      Text(SettingsService.isGuestLogin() ? 'Khách' : (user?.name ?? ''), style: theme.textTheme.titleLarge),
                    ],
                  ),
                ],
              ),
            ),
            BlocBuilder<TransactionCubit, TransactionState>(
              builder: (context, transactionState) {
                final monthlyData = transactionState.status == TransactionStateStatus.loaded
                    ? _calculateMonthlyData(transactionState.transactionsList)
                    : <int, Map<String, double>>{};
                final maxAmount = _getMaxAmount(monthlyData);
                final divisor = 10000.0;
                final incomeSpots = List.generate(12, (i) => FlSpot((i + 1).toDouble(), _convertAmount(monthlyData[i + 1]?['income'] ?? 0, divisor)));
                final expenseSpots = List.generate(12, (i) => FlSpot((i + 1).toDouble(), _convertAmount(monthlyData[i + 1]?['expense'] ?? 0, divisor)));

                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
                  height: 200,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildLegend(AppColors.green, 'Thu nhập'),
                          const SizedBox(width: 20),
                          _buildLegend(AppColors.red, 'Chi tiêu'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: transactionState.status == TransactionStateStatus.loading
                            ? const Center(child: CircularProgressIndicator())
                            : _buildScrollableChart(incomeSpots, expenseSpots, monthlyData, divisor, theme),
                      ),
                    ],
                  ),
                );
              },
            ),
            BlocConsumer<TransactionCubit, TransactionState>(
              listener: (context, state) {
                if (state.status == TransactionStateStatus.error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'Lỗi tải giao dịch')));
                }
              },
              builder: (context, state) {
                final transactionsList = state.status == TransactionStateStatus.loaded ? state.transactionsList : null;
                return Expanded(
                  child: transactionsList?.isEmpty ?? true
                      ? const Center(child: Text('Không có giao dịch nào'))
                      : ListView.builder(
                          itemCount: transactionsList?.length ?? 0,
                          itemBuilder: (context, index) {
                            final date = transactionsList!.keys.elementAt(index);
                            final transactions = transactionsList[date]!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDateHeader(DateFormat('dd/MM/yyyy').format(date), DateFormat('EEEE').format(date), context),
                                ...transactions.map((tx) => _buildTransactionItem(context, tx)),
                              ],
                            );
                          },
                        ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDateHeader(String date, String day, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: const TextStyle(color: Colors.grey)),
          Text(day, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transactionsmodels tx) {
    final theme = Theme.of(context);
    final account = context.read<ManageMoneyCubit>().state.listAccounts?.firstWhere((acc) => acc.id == tx.accountId, orElse: () => MoneySource(name: 'Không rõ', balance: 0, isActive: true));
    final category = IconMapping.getCategoryByName(tx.categoriesId);
    final isIncome = tx.type == TransactionType.income;

    return Slidable(
      key: ValueKey(tx.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _showDeleteConfirmation(context, tx),
            backgroundColor: AppColors.red,
            icon: Icons.delete,
            label: 'Xóa',
          ),
        ],
      ),
      child: ListTile(
        onTap: () => Navigator.pushNamed(context, '/add', arguments: tx),
        leading: CircleAvatar(
          backgroundColor: (ColorUtils.parseColor(category?.color ?? '0xFF2196F3')).withOpacity(0.2),
          child: Icon(IconMapping.stringToIcon(category?.icon ?? ''), color: ColorUtils.parseColor(category?.color ?? '0xFF2196F3')),
        ),
        title: Text(tx.categoriesId, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(tx.note ?? ''),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncome ? '+' : '-'} ${_formatAmount(tx.amount, isUSD: account?.currency == CurrencyType.usd)}',
              style: TextStyle(color: isIncome ? AppColors.green : AppColors.red, fontWeight: FontWeight.bold),
            ),
            Text(account?.name ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Transactionsmodels tx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: const Text('Bạn có chắc chắn muốn xóa giao dịch này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              context.read<TransactionCubit>().deleteTransaction(tx.id);
              Navigator.pop(ctx);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLoginPromptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yêu cầu đăng nhập'),
        content: const Text('Vui lòng đăng nhập để quản lý hồ sơ và đồng bộ dữ liệu.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }
}
