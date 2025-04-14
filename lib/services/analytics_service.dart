import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/income.dart';
import 'package:expense_tracker/services/settings_service.dart';
import 'package:intl/intl.dart';

class AnalyticsService {
  // Get expenses by category
  static Map<Category, double> getExpensesByCategory(List<Expense> expenses) {
    Map<Category, double> categoryMap = {};

    for (var expense in expenses) {
      if (categoryMap.containsKey(expense.category)) {
        categoryMap[expense.category] =
            categoryMap[expense.category]! + expense.amount;
      } else {
        categoryMap[expense.category] = expense.amount;
      }
    }

    return categoryMap;
  }

  // Get incomes by source
  static Map<IncomeSource, double> getIncomesBySource(List<Income> incomes) {
    Map<IncomeSource, double> sourceMap = {};

    for (var income in incomes) {
      if (sourceMap.containsKey(income.source)) {
        sourceMap[income.source] = sourceMap[income.source]! + income.amount;
      } else {
        sourceMap[income.source] = income.amount;
      }
    }

    return sourceMap;
  }

  // Get monthly expenses
  static Map<String, double> getMonthlyExpenses(List<Expense> expenses) {
    Map<String, double> monthlyExpenses = {};
    final dateFormat = DateFormat('yyyy-MM');

    for (var expense in expenses) {
      final monthKey = dateFormat.format(expense.date);
      if (monthlyExpenses.containsKey(monthKey)) {
        monthlyExpenses[monthKey] = monthlyExpenses[monthKey]! + expense.amount;
      } else {
        monthlyExpenses[monthKey] = expense.amount;
      }
    }

    return monthlyExpenses;
  }

  // Get monthly incomes
  static Map<String, double> getMonthlyIncomes(List<Income> incomes) {
    Map<String, double> monthlyIncomes = {};
    final dateFormat = DateFormat('yyyy-MM');

    for (var income in incomes) {
      final monthKey = dateFormat.format(income.date);
      if (monthlyIncomes.containsKey(monthKey)) {
        monthlyIncomes[monthKey] = monthlyIncomes[monthKey]! + income.amount;
      } else {
        monthlyIncomes[monthKey] = income.amount;
      }
    }

    return monthlyIncomes;
  }

  // Calculate monthly balance (income - expenses)
  static Map<String, double> getMonthlyBalance(
    List<Expense> expenses,
    List<Income> incomes,
  ) {
    Map<String, double> monthlyBalance = {};
    final monthlyExpenses = getMonthlyExpenses(expenses);
    final monthlyIncomes = getMonthlyIncomes(incomes);

    // First add all incomes
    monthlyIncomes.forEach((month, amount) {
      monthlyBalance[month] = amount;
    });

    // Then subtract expenses
    monthlyExpenses.forEach((month, amount) {
      if (monthlyBalance.containsKey(month)) {
        monthlyBalance[month] = monthlyBalance[month]! - amount;
      } else {
        monthlyBalance[month] = -amount;
      }
    });

    return monthlyBalance;
  }

  // Get expenses for a specific period
  static double getTotalExpensesForPeriod(
    List<Expense> expenses,
    DateTime startDate,
    DateTime endDate,
  ) {
    return expenses
        .where(
          (expense) =>
              expense.date.isAfter(
                startDate.subtract(const Duration(days: 1)),
              ) &&
              expense.date.isBefore(endDate.add(const Duration(days: 1))),
        )
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  // Get incomes for a specific period
  static double getTotalIncomesForPeriod(
    List<Income> incomes,
    DateTime startDate,
    DateTime endDate,
  ) {
    return incomes
        .where(
          (income) =>
              income.date.isAfter(
                startDate.subtract(const Duration(days: 1)),
              ) &&
              income.date.isBefore(endDate.add(const Duration(days: 1))),
        )
        .fold(0, (sum, income) => sum + income.amount);
  }

  // Get expense growth rate (comparing current month to previous month)
  static double getExpenseGrowthRate(List<Expense> expenses) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final previousMonth = DateTime(now.year, now.month - 1, 1);
    final lastDayOfPreviousMonth = DateTime(now.year, now.month, 0);

    final currentMonthExpenses = getTotalExpensesForPeriod(
      expenses,
      currentMonth,
      now,
    );
    final previousMonthExpenses = getTotalExpensesForPeriod(
      expenses,
      previousMonth,
      lastDayOfPreviousMonth,
    );

    if (previousMonthExpenses == 0) return 0;

    return ((currentMonthExpenses - previousMonthExpenses) /
            previousMonthExpenses) *
        100;
  }

  // Get income growth rate (comparing current month to previous month)
  static double getIncomeGrowthRate(List<Income> incomes) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final previousMonth = DateTime(now.year, now.month - 1, 1);
    final lastDayOfPreviousMonth = DateTime(now.year, now.month, 0);

    final currentMonthIncomes = getTotalIncomesForPeriod(
      incomes,
      currentMonth,
      now,
    );
    final previousMonthIncomes = getTotalIncomesForPeriod(
      incomes,
      previousMonth,
      lastDayOfPreviousMonth,
    );

    if (previousMonthIncomes == 0) return 0;

    return ((currentMonthIncomes - previousMonthIncomes) /
            previousMonthIncomes) *
        100;
  }

  // Get top expense categories
  static List<MapEntry<Category, double>> getTopExpenseCategories(
    List<Expense> expenses, {
    int limit = 3,
  }) {
    final categoryMap = getExpensesByCategory(expenses);
    final sortedEntries = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.take(limit).toList();
  }

  // Format currency
  static String formatCurrency(double amount) {
    // Use the settings service for currency formatting
    return SettingsService.formatCurrency(amount);
  }
}
