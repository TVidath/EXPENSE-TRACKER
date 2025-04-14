import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/income.dart';

class SearchService {
  // Filter expenses by category
  static List<Expense> filterExpensesByCategory(
    List<Expense> expenses,
    Category category,
  ) {
    return expenses.where((expense) => expense.category == category).toList();
  }

  // Filter expenses by date range
  static List<Expense> filterExpensesByDateRange(
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
        .toList();
  }

  // Filter expenses by amount range
  static List<Expense> filterExpensesByAmountRange(
    List<Expense> expenses,
    double minAmount,
    double maxAmount,
  ) {
    return expenses
        .where(
          (expense) =>
              expense.amount >= minAmount && expense.amount <= maxAmount,
        )
        .toList();
  }

  // Search expenses by title keywords
  static List<Expense> searchExpensesByTitle(
    List<Expense> expenses,
    String query,
  ) {
    final lowercaseQuery = query.toLowerCase();
    return expenses
        .where(
          (expense) => expense.title.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  // Advanced search for expenses with multiple criteria
  static List<Expense> advancedSearchExpenses({
    required List<Expense> expenses,
    String? titleQuery,
    Category? category,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
  }) {
    List<Expense> filteredExpenses = List.from(expenses);

    if (titleQuery != null && titleQuery.isNotEmpty) {
      filteredExpenses = searchExpensesByTitle(filteredExpenses, titleQuery);
    }

    if (category != null) {
      filteredExpenses = filterExpensesByCategory(filteredExpenses, category);
    }

    if (startDate != null && endDate != null) {
      filteredExpenses = filterExpensesByDateRange(
        filteredExpenses,
        startDate,
        endDate,
      );
    }

    if (minAmount != null && maxAmount != null) {
      filteredExpenses = filterExpensesByAmountRange(
        filteredExpenses,
        minAmount,
        maxAmount,
      );
    }

    return filteredExpenses;
  }

  // Filter incomes by source
  static List<Income> filterIncomesBySource(
    List<Income> incomes,
    IncomeSource source,
  ) {
    return incomes.where((income) => income.source == source).toList();
  }

  // Filter incomes by date range
  static List<Income> filterIncomesByDateRange(
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
        .toList();
  }

  // Filter incomes by amount range
  static List<Income> filterIncomesByAmountRange(
    List<Income> incomes,
    double minAmount,
    double maxAmount,
  ) {
    return incomes
        .where(
          (income) => income.amount >= minAmount && income.amount <= maxAmount,
        )
        .toList();
  }

  // Search incomes by title keywords
  static List<Income> searchIncomesByTitle(List<Income> incomes, String query) {
    final lowercaseQuery = query.toLowerCase();
    return incomes
        .where((income) => income.title.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  // Advanced search for incomes with multiple criteria
  static List<Income> advancedSearchIncomes({
    required List<Income> incomes,
    String? titleQuery,
    IncomeSource? source,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
  }) {
    List<Income> filteredIncomes = List.from(incomes);

    if (titleQuery != null && titleQuery.isNotEmpty) {
      filteredIncomes = searchIncomesByTitle(filteredIncomes, titleQuery);
    }

    if (source != null) {
      filteredIncomes = filterIncomesBySource(filteredIncomes, source);
    }

    if (startDate != null && endDate != null) {
      filteredIncomes = filterIncomesByDateRange(
        filteredIncomes,
        startDate,
        endDate,
      );
    }

    if (minAmount != null && maxAmount != null) {
      filteredIncomes = filterIncomesByAmountRange(
        filteredIncomes,
        minAmount,
        maxAmount,
      );
    }

    return filteredIncomes;
  }
}
