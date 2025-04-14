import 'package:uuid/uuid.dart';
import 'package:expense_tracker/models/expense.dart';

class Budget {
  final String id;
  final String title;
  final double amount;
  final Category category;
  final DateTime startDate;
  final DateTime endDate;
  final BudgetPeriod period;

  Budget({
    String? id,
    required this.title,
    required this.amount,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.period,
  }) : id = id ?? const Uuid().v4();

  // Calculate the remaining budget based on expenses
  double calculateRemaining(List<Expense> expenses) {
    final relevantExpenses = expenses.where((expense) {
      return expense.category == category &&
          expense.date.isAfter(startDate) &&
          expense.date.isBefore(endDate.add(const Duration(days: 1)));
    });

    final totalSpent = relevantExpenses.fold(
      0.0,
      (previousValue, expense) => previousValue + expense.amount,
    );

    return amount - totalSpent;
  }

  // Calculate percentage spent
  double calculatePercentSpent(List<Expense> expenses) {
    final remaining = calculateRemaining(expenses);
    final percentSpent = ((amount - remaining) / amount) * 100;
    return percentSpent.clamp(0.0, 100.0);
  }

  // Check if budget is exceeded
  bool isBudgetExceeded(List<Expense> expenses) {
    return calculateRemaining(expenses) < 0;
  }
}

enum BudgetPeriod { daily, weekly, monthly, yearly, custom }
