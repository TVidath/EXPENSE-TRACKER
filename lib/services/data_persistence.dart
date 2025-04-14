import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/income.dart';
import 'package:expense_tracker/services/settings_service.dart';
import 'package:flutter/material.dart';

class DataPersistence {
  static const String _expensesKey = 'expenses';
  static const String _incomesKey = 'incomes';

  static Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = expenses
        .map((e) => {
              'id': e.id,
              'title': e.title,
              'amount': e.amount,
              'date': e.date.toIso8601String(),
              'category': e.category.index,
              'originalCurrency': e.originalCurrency,
              'originalAmount': e.originalAmount,
            })
        .toList();
    await prefs.setString(_expensesKey, jsonEncode(expensesJson));
  }

  static Future<void> saveIncomes(List<Income> incomes) async {
    final prefs = await SharedPreferences.getInstance();
    final incomesJson = incomes
        .map((e) => {
              'id': e.id,
              'title': e.title,
              'amount': e.amount,
              'date': e.date.toIso8601String(),
              'source': e.source.index,
              'originalCurrency': e.originalCurrency,
              'originalAmount': e.originalAmount,
            })
        .toList();
    await prefs.setString(_incomesKey, jsonEncode(incomesJson));
  }

  static Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getString(_expensesKey);
    if (expensesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(expensesJson);
    return decoded
        .map((e) => Expense(
              id: e['id'],
              title: e['title'],
              amount: e['amount'],
              date: DateTime.parse(e['date']),
              category: Category.values[e['category']],
              originalCurrency: e['originalCurrency'],
              originalAmount: e['originalAmount'],
            ))
        .toList();
  }

  static Future<List<Income>> loadIncomes() async {
    final prefs = await SharedPreferences.getInstance();
    final incomesJson = prefs.getString(_incomesKey);
    if (incomesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(incomesJson);
    return decoded
        .map((e) => Income(
              id: e['id'],
              title: e['title'],
              amount: e['amount'],
              date: DateTime.parse(e['date']),
              source: IncomeSource.values[e['source']],
              originalCurrency: e['originalCurrency'],
              originalAmount: e['originalAmount'],
            ))
        .toList();
  }

  // Convert all amounts to a new default currency
  static Future<void> convertAllAmountsToNewCurrency(
      String oldCurrency, String newCurrency) async {
    try {
      // Convert expenses
      final expenses = await loadExpenses();
      final updatedExpenses = expenses.map((expense) {
        double newAmount;

        if (expense.wasConverted) {
          // If it was already converted, convert from the original currency
          newAmount = SettingsService.convertCurrency(
              expense.originalAmount!, expense.originalCurrency!, newCurrency);
        } else {
          // Convert from old default currency to new default currency
          newAmount = SettingsService.convertCurrency(
              expense.amount, oldCurrency, newCurrency);
        }

        return expense.copyWith(amount: newAmount);
      }).toList();

      await saveExpenses(updatedExpenses);

      // Convert incomes
      final incomes = await loadIncomes();
      final updatedIncomes = incomes.map((income) {
        double newAmount;

        if (income.wasConverted) {
          // If it was already converted, convert from the original currency
          newAmount = SettingsService.convertCurrency(
              income.originalAmount!, income.originalCurrency!, newCurrency);
        } else {
          // Convert from old default currency to new default currency
          newAmount = SettingsService.convertCurrency(
              income.amount, oldCurrency, newCurrency);
        }

        return income.copyWith(amount: newAmount);
      }).toList();

      await saveIncomes(updatedIncomes);
    } catch (e) {
      debugPrint('Error converting amounts: $e');
    }
  }
}
