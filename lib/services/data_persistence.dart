import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/income.dart';

class DataPersistence {
  static const String _expensesKey = 'expenses';
  static const String _incomesKey = 'incomes';

  static Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson =
        expenses
            .map(
              (e) => {
                'id': e.id,
                'title': e.title,
                'amount': e.amount,
                'date': e.date.toIso8601String(),
                'category': e.category.index,
              },
            )
            .toList();
    await prefs.setString(_expensesKey, jsonEncode(expensesJson));
  }

  static Future<void> saveIncomes(List<Income> incomes) async {
    final prefs = await SharedPreferences.getInstance();
    final incomesJson =
        incomes
            .map(
              (e) => {
                'id': e.id,
                'title': e.title,
                'amount': e.amount,
                'date': e.date.toIso8601String(),
                'source': e.source.index,
              },
            )
            .toList();
    await prefs.setString(_incomesKey, jsonEncode(incomesJson));
  }

  static Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getString(_expensesKey);
    if (expensesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(expensesJson);
    return decoded
        .map(
          (e) => Expense(
            id: e['id'],
            title: e['title'],
            amount: e['amount'],
            date: DateTime.parse(e['date']),
            category: Category.values[e['category']],
          ),
        )
        .toList();
  }

  static Future<List<Income>> loadIncomes() async {
    final prefs = await SharedPreferences.getInstance();
    final incomesJson = prefs.getString(_incomesKey);
    if (incomesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(incomesJson);
    return decoded
        .map(
          (e) => Income(
            id: e['id'],
            title: e['title'],
            amount: e['amount'],
            date: DateTime.parse(e['date']),
            source: IncomeSource.values[e['source']],
          ),
        )
        .toList();
  }
}
