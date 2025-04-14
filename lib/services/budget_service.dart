import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/models/budget.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';

class BudgetService {
  static const String _budgetsKey = 'budgets';

  // Save budgets to persistent storage
  static Future<void> saveBudgets(List<Budget> budgets) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final budgetsJson =
          budgets
              .map(
                (budget) => {
                  'id': budget.id,
                  'title': budget.title,
                  'amount': budget.amount,
                  'category': budget.category.index,
                  'startDate': budget.startDate.toIso8601String(),
                  'endDate': budget.endDate.toIso8601String(),
                  'period': budget.period.index,
                },
              )
              .toList();
      await prefs.setString(_budgetsKey, jsonEncode(budgetsJson));
    } catch (e) {
      debugPrint('Error saving budgets: $e');
    }
  }

  // Load budgets from persistent storage
  static Future<List<Budget>> loadBudgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final budgetsJson = prefs.getString(_budgetsKey);
      if (budgetsJson == null) return [];

      final List<dynamic> decoded = jsonDecode(budgetsJson);
      return decoded
          .map(
            (budget) => Budget(
              id: budget['id'],
              title: budget['title'],
              amount: budget['amount'],
              category: Category.values[budget['category']],
              startDate: DateTime.parse(budget['startDate']),
              endDate: DateTime.parse(budget['endDate']),
              period: BudgetPeriod.values[budget['period']],
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Error loading budgets: $e');
      return [];
    }
  }

  // Add a new budget
  static Future<void> addBudget(Budget budget) async {
    final budgets = await loadBudgets();
    budgets.add(budget);
    await saveBudgets(budgets);
  }

  // Delete a budget
  static Future<void> deleteBudget(String id) async {
    final budgets = await loadBudgets();
    budgets.removeWhere((budget) => budget.id == id);
    await saveBudgets(budgets);
  }

  // Update a budget
  static Future<void> updateBudget(Budget updatedBudget) async {
    final budgets = await loadBudgets();
    final index = budgets.indexWhere((budget) => budget.id == updatedBudget.id);
    if (index != -1) {
      budgets[index] = updatedBudget;
      await saveBudgets(budgets);
    }
  }

  // Get budgets by category
  static Future<List<Budget>> getBudgetsByCategory(Category category) async {
    final budgets = await loadBudgets();
    return budgets.where((budget) => budget.category == category).toList();
  }

  // Get active budgets (current date falls within budget period)
  static Future<List<Budget>> getActiveBudgets() async {
    final budgets = await loadBudgets();
    final now = DateTime.now();
    return budgets
        .where(
          (budget) =>
              now.isAfter(budget.startDate) && now.isBefore(budget.endDate),
        )
        .toList();
  }

  // Check if a budget exceeds its limit
  static Future<List<Budget>> getExceededBudgets(List<Expense> expenses) async {
    final budgets = await loadBudgets();
    return budgets
        .where((budget) => budget.isBudgetExceeded(expenses))
        .toList();
  }
}
