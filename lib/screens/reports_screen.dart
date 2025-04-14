import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/income.dart';
import 'package:expense_tracker/services/analytics_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  final List<Expense> expenses;
  final List<Income> incomes;

  const ReportsScreen({
    Key? key,
    required this.expenses,
    required this.incomes,
  }) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _timePeriod = 'This Month';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _updateDateRange('This Month');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateDateRange(String period) {
    final now = DateTime.now();
    setState(() {
      _timePeriod = period;
      switch (period) {
        case 'This Week':
          // Start from monday of this week
          _startDate = now.subtract(Duration(days: now.weekday - 1));
          _endDate = now;
          break;
        case 'This Month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = now;
          break;
        case 'Last 3 Months':
          _startDate = DateTime(now.year, now.month - 3, 1);
          _endDate = now;
          break;
        case 'This Year':
          _startDate = DateTime(now.year, 1, 1);
          _endDate = now;
          break;
        case 'Custom':
          // Keep existing dates for custom range
          break;
      }
    });
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _timePeriod = 'Custom';
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  List<Expense> get _filteredExpenses {
    return widget.expenses
        .where((expense) =>
            expense.date
                .isAfter(_startDate.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(_endDate.add(const Duration(days: 1))))
        .toList();
  }

  List<Income> get _filteredIncomes {
    return widget.incomes
        .where((income) =>
            income.date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
            income.date.isBefore(_endDate.add(const Duration(days: 1))))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = _filteredExpenses;
    final filteredIncomes = _filteredIncomes;

    final expensesByCategory =
        AnalyticsService.getExpensesByCategory(filteredExpenses);
    final incomesBySource =
        AnalyticsService.getIncomesBySource(filteredIncomes);

    final totalExpenses =
        filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final totalIncomes =
        filteredIncomes.fold(0.0, (sum, income) => sum + income.amount);
    final balance = totalIncomes - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Expenses'),
            Tab(text: 'Income'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Period: '),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _timePeriod,
                  items: [
                    'This Week',
                    'This Month',
                    'Last 3 Months',
                    'This Year',
                    'Custom',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue == 'Custom') {
                      _selectCustomDateRange();
                    } else if (newValue != null) {
                      _updateDateRange(newValue);
                    }
                  },
                ),
                const Spacer(),
                Text(
                  '${DateFormat.yMd().format(_startDate)} - ${DateFormat.yMd().format(_endDate)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Overview Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Financial Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryCard(
                        totalIncomes: totalIncomes,
                        totalExpenses: totalExpenses,
                        balance: balance,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Income vs Expenses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AspectRatio(
                        aspectRatio: 1.5,
                        child: _buildPieChart(totalIncomes, totalExpenses),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Top Expense Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTopExpensesList(expensesByCategory),
                    ],
                  ),
                ),

                // Expenses Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Expense Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AspectRatio(
                        aspectRatio: 1.3,
                        child: _buildExpenseCategoryChart(expensesByCategory),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Category Breakdown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryBreakdownList(
                          expensesByCategory, totalExpenses),
                    ],
                  ),
                ),

                // Income Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Income Sources',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AspectRatio(
                        aspectRatio: 1.3,
                        child: _buildIncomeSourceChart(incomesBySource),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Source Breakdown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSourceBreakdownList(incomesBySource, totalIncomes),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required double totalIncomes,
    required double totalExpenses,
    required double balance,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Income:'),
                Text(
                  AnalyticsService.formatCurrency(totalIncomes),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Expenses:'),
                Text(
                  AnalyticsService.formatCurrency(totalExpenses),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Balance:'),
                Text(
                  AnalyticsService.formatCurrency(balance),
                  style: TextStyle(
                    color: balance >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: totalExpenses / (totalIncomes > 0 ? totalIncomes : 1),
              backgroundColor: Colors.green.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                totalExpenses > totalIncomes ? Colors.red : Colors.orange,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              totalIncomes > 0
                  ? 'You spent ${((totalExpenses / totalIncomes) * 100).toStringAsFixed(1)}% of your income'
                  : 'No income recorded yet',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(double income, double expenses) {
    return income == 0 && expenses == 0
        ? const Center(child: Text('No data to display'))
        : PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: income,
                  title: 'Income',
                  color: Colors.green,
                  radius: 100,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PieChartSectionData(
                  value: expenses,
                  title: 'Expenses',
                  color: Colors.red,
                  radius: 100,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          );
  }

  Widget _buildTopExpensesList(Map<Category, double> expensesByCategory) {
    final topExpenses =
        AnalyticsService.getTopExpenseCategories(_filteredExpenses);

    if (topExpenses.isEmpty) {
      return const Center(child: Text('No expenses recorded yet'));
    }

    return Column(
      children: topExpenses.map((entry) {
        return ListTile(
          leading: Icon(
            categoryIcons[entry.key],
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(entry.key.name.toUpperCase()),
          trailing: Text(
            AnalyticsService.formatCurrency(entry.value),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExpenseCategoryChart(Map<Category, double> expensesByCategory) {
    final items = expensesByCategory.entries.toList();

    if (items.isEmpty) {
      return const Center(child: Text('No expenses recorded yet'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: items.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value >= 0 && value < items.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      items[value.toInt()]
                          .key
                          .name
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(
          items.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: items[index].value,
                color: Theme.of(context).colorScheme.primary,
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdownList(
      Map<Category, double> expensesByCategory, double totalExpenses) {
    if (expensesByCategory.isEmpty) {
      return const Center(child: Text('No expenses recorded yet'));
    }

    final items = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: items.map((entry) {
        final percentage =
            totalExpenses > 0 ? (entry.value / totalExpenses) * 100 : 0;

        return ListTile(
          leading: Icon(
            categoryIcons[entry.key],
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(entry.key.name.toUpperCase()),
          subtitle: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AnalyticsService.formatCurrency(entry.value),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIncomeSourceChart(Map<IncomeSource, double> incomesBySource) {
    final items = incomesBySource.entries.toList();

    if (items.isEmpty) {
      return const Center(child: Text('No income recorded yet'));
    }

    // Create a map of colors for income sources
    final Map<IncomeSource, Color> sourceColors = {
      IncomeSource.salary: Colors.blue,
      IncomeSource.business: Colors.purple,
      IncomeSource.investment: Colors.teal,
      IncomeSource.other: Colors.amber,
    };

    return PieChart(
      PieChartData(
        sections: items.map((entry) {
          return PieChartSectionData(
            value: entry.value,
            title: '${entry.key.name}\n${(entry.value).toStringAsFixed(0)}',
            color: sourceColors[entry.key] ?? Colors.grey,
            radius: 100,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          );
        }).toList(),
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildSourceBreakdownList(
      Map<IncomeSource, double> incomesBySource, double totalIncomes) {
    if (incomesBySource.isEmpty) {
      return const Center(child: Text('No income recorded yet'));
    }

    final items = incomesBySource.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Create a map of colors for income sources
    final Map<IncomeSource, Color> sourceColors = {
      IncomeSource.salary: Colors.blue,
      IncomeSource.business: Colors.purple,
      IncomeSource.investment: Colors.teal,
      IncomeSource.other: Colors.amber,
    };

    return Column(
      children: items.map((entry) {
        final percentage =
            totalIncomes > 0 ? (entry.value / totalIncomes) * 100 : 0;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: sourceColors[entry.key] ?? Colors.grey,
            child: Icon(
              _getIncomeSourceIcon(entry.key),
              color: Colors.white,
            ),
          ),
          title: Text(entry.key.name.toUpperCase()),
          subtitle: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
                sourceColors[entry.key] ?? Colors.grey),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AnalyticsService.formatCurrency(entry.value),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getIncomeSourceIcon(IncomeSource source) {
    switch (source) {
      case IncomeSource.salary:
        return Icons.work;
      case IncomeSource.business:
        return Icons.store;
      case IncomeSource.investment:
        return Icons.trending_up;
      case IncomeSource.other:
        return Icons.attach_money;
    }
  }
}
