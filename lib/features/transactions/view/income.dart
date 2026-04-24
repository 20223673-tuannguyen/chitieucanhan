// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:btl/features/transactions/Cubit/transactionCubit.dart';
import 'package:btl/features/transactions/Cubit/transctionState.dart';
import 'package:btl/features/transactions/models/transactionsModels.dart';
import 'package:btl/features/Categories/cubit/CategoriesCubit.dart';
import 'package:btl/features/Categories/cubit/CategoriesState.dart';
import 'package:btl/features/Categories/models/categoriesModels.dart';
import 'package:btl/shared/utils/statistics_utils.dart';
import 'package:btl/shared/utils/mappingIcon.dart';

enum StatisticsView { daily, weekly, monthly, yearly }

class Income extends StatefulWidget {
  const Income({super.key});

  @override
  State<Income> createState() => _IncomeState();
}

class _IncomeState extends State<Income> {
  StatisticsView selectedView = StatisticsView.daily;
  String selectedCategory = 'Tất cả danh mục';
  DateTime selectedDate = DateTime.now();

  double totalIncome = 0.0;
  Map<String, double> categoryTotals = {};
  List<MapEntry<DateTime, double>> chartData = [];
  List<MapEntry<String, double>> pieChartData = [];

  List<String> categories = ['Tất cả danh mục'];
  List<String> availableYears = [];
  List<String> availableMonths = [];
  List<String> availableWeeks = [];

  @override
  void initState() {
    super.initState();
    _initializeAvailableOptions();
    context.read<Categoriescubit>().loadCategories();
  }

  void _initializeAvailableOptions() {
    final now = DateTime.now();
    availableYears = List.generate(4, (index) => (now.year - index).toString());
    availableMonths = List.generate(12, (index) => '${index + 1}/${now.year}');
    _updateAvailableWeeks();
  }

  void _updateAvailableWeeks() {
    availableWeeks.clear();
    final year = selectedDate.year;
    final month = selectedDate.month;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    DateTime current = firstDay;
    int weekNumber = 1;

    while (current.isBefore(lastDay) || current.isAtSameMomentAs(lastDay)) {
      final weekStart = current.subtract(Duration(days: current.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      availableWeeks.add('Tuần $weekNumber (${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month})');
      current = current.add(const Duration(days: 7));
      weekNumber++;
    }
  }

  void _calculateStatistics(Map<DateTime, List<Transactionsmodels>> transactions) {
    final (startDate, endDate) = _getDateRange();
    final filteredTransactions = _filterTransactions(transactions, startDate, endDate);

    totalIncome = 0.0;
    categoryTotals = {};
    
    filteredTransactions.forEach((date, txList) {
      for (var tx in txList) {
        totalIncome += tx.amount;
        final catName = tx.categoriesId;
        categoryTotals[catName] = (categoryTotals[catName] ?? 0.0) + tx.amount;
      }
    });

    chartData = _calculateChartData(filteredTransactions, startDate, endDate);
    pieChartData = StatisticsUtils.getPieChartData(categoryTotals, 5);
    setState(() {});
  }

  (DateTime, DateTime) _getDateRange() {
    DateTime startDate, endDate;
    switch (selectedView) {
      case StatisticsView.daily:
        startDate = DateTime(selectedDate.year, selectedDate.month, 1);
        endDate = DateTime(selectedDate.year, selectedDate.month + 1, 0);
        break;
      case StatisticsView.weekly:
        final weekStart = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
        startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
        endDate = startDate.add(const Duration(days: 6));
        break;
      case StatisticsView.monthly:
        startDate = DateTime(selectedDate.year, 1, 1);
        endDate = DateTime(selectedDate.year, 12, 31);
        break;
      case StatisticsView.yearly:
        startDate = DateTime(selectedDate.year - 3, 1, 1);
        endDate = DateTime(selectedDate.year, 12, 31);
        break;
    }
    return (startDate, endDate);
  }

  Map<DateTime, List<Transactionsmodels>> _filterTransactions(
    Map<DateTime, List<Transactionsmodels>> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final filtered = <DateTime, List<Transactionsmodels>>{};
    transactions.forEach((date, txList) {
      if (date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(endDate.add(const Duration(days: 1)))) {
        final categoryFiltered = txList.where((tx) {
          final isIncome = tx.type == TransactionType.income;
          final matchesCategory = selectedCategory == 'Tất cả danh mục' || tx.categoriesId == selectedCategory;
          return isIncome && matchesCategory;
        }).toList();

        if (categoryFiltered.isNotEmpty) {
          filtered[date] = categoryFiltered;
        }
      }
    });
    return filtered;
  }

  List<MapEntry<DateTime, double>> _calculateChartData(
    Map<DateTime, List<Transactionsmodels>> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final data = <MapEntry<DateTime, double>>[];
    DateTime current = startDate;
    while (current.isBefore(endDate.add(const Duration(days: 1)))) {
      double total = 0;
      if (selectedView == StatisticsView.daily) {
        for (var tx in (transactions[current] ?? [])) {
          total += tx.amount;
        }
        data.add(MapEntry(current, total));
        current = current.add(const Duration(days: 1));
      } else {
        data.add(MapEntry(current, 0));
        current = current.add(const Duration(days: 1));
      }
      if (data.length > 31) break;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<TransactionCubit, TransactionState>(
          listener: (context, state) {
            if (state.status == TransactionStateStatus.loaded) {
              _calculateStatistics(state.transactionsList);
            }
          },
        ),
        BlocListener<Categoriescubit, CategoriesState>(
          listener: (context, state) {
            if (state.status == CategoriesStatus.loaded) {
              setState(() {
                categories = ['Tất cả danh mục', ...state.categoriesIncome.map((c) => c.name)];
              });
              context.read<TransactionCubit>().fetchTransactionsByDate();
            }
          },
        ),
      ],
      child: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryHeader(theme),
                const SizedBox(height: 24),
                _buildFilterControls(theme),
                const SizedBox(height: 24),
                _buildBarChart(theme),
                const SizedBox(height: 32),
                _buildPieChartSection(theme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Thu nhập', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            Text(
              '+${totalIncome.toStringAsFixed(0)} ₫',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterControls(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDropdown(_getViewName(selectedView), () => _showViewSelector())),
            const SizedBox(width: 12),
            Expanded(child: _buildDropdown(selectedCategory, () => _showCategorySelector())),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(text, overflow: TextOverflow.ellipsis)),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(ThemeData theme) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
      child: BarChart(
        BarChartData(
          barGroups: chartData.asMap().entries.map((e) {
            return BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.value, color: Colors.green, width: 15)]);
          }).toList(),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }

  Widget _buildPieChartSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Thu nhập theo danh mục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: pieChartData.map((e) {
                return PieChartSectionData(value: e.value, title: '${e.value.toStringAsFixed(0)}%', color: Colors.green, radius: 50);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  String _getViewName(StatisticsView view) {
    switch (view) {
      case StatisticsView.daily: return 'Theo ngày';
      case StatisticsView.weekly: return 'Theo tuần';
      case StatisticsView.monthly: return 'Theo tháng';
      case StatisticsView.yearly: return 'Theo năm';
    }
  }

  void _showViewSelector() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: StatisticsView.values.map((v) => ListTile(
          title: Text(_getViewName(v)),
          onTap: () { setState(() => selectedView = v); Navigator.pop(ctx); },
        )).toList(),
      ),
    );
  }

  void _showCategorySelector() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: categories.map((c) => ListTile(
          title: Text(c),
          onTap: () { setState(() => selectedCategory = c); Navigator.pop(ctx); },
        )).toList(),
      ),
    );
  }
}
