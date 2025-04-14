import 'package:expense_tracker/addexpenses.dart';
import 'package:expense_tracker/addincome.dart';
import 'package:expense_tracker/expenses_list.dart';
import 'package:expense_tracker/incomes_list.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/income.dart';
import 'package:expense_tracker/services/data_persistence.dart';
import 'package:flutter/material.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});
  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends State<Expenses> {
  List<Expense> _registeredExpenses = [];
  List<Income> _registeredIncomes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final expenses = await DataPersistence.loadExpenses();
    final incomes = await DataPersistence.loadIncomes();
    setState(() {
      _registeredExpenses = expenses;
      _registeredIncomes = incomes;
    });
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return AddExpense(onAddExpense: _addExpense);
      },
    );
  }

  void _openAddIncomeOverlay() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return AddIncome(onAddIncome: _addIncome);
      },
    );
  }

  void _addExpense(Expense expense) async {
    setState(() {
      _registeredExpenses.add(expense);
    });
    await DataPersistence.saveExpenses(_registeredExpenses);
  }

  void _addIncome(Income income) async {
    setState(() {
      _registeredIncomes.add(income);
    });
    await DataPersistence.saveIncomes(_registeredIncomes);
  }

  void _removeExpense(Expense expense) async {
    setState(() {
      _registeredExpenses.remove(expense);
    });
    await DataPersistence.saveExpenses(_registeredExpenses);
  }

  void _removeIncome(Income income) async {
    setState(() {
      _registeredIncomes.remove(income);
    });
    await DataPersistence.saveIncomes(_registeredIncomes);
  }

  double get _totalExpenses {
    return _registeredExpenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  double get _totalIncome {
    return _registeredIncomes.fold(0, (sum, income) => sum + income.amount);
  }

  double get _balance {
    return _totalIncome - _totalExpenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            onPressed: _openAddIncomeOverlay,
            icon: const Icon(Icons.add_circle_outline),
          ),
          IconButton(
            onPressed: _openAddExpenseOverlay,
            icon: const Icon(Icons.remove_circle_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Income:'),
                      Text(
                        '\$${_totalIncome.toStringAsFixed(2)}',
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
                        '\$${_totalExpenses.toStringAsFixed(2)}',
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
                        '\$${_balance.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: _balance >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Text('Incomes'),
          Expanded(
            child: IncomesList(
              incomes: _registeredIncomes,
              onRemoveIncome: _removeIncome,
            ),
          ),
          const Text('Expenses'),
          Expanded(
            child: ExpensesList(
              expenses: _registeredExpenses,
              onRemoveExpense: _removeExpense,
            ),
          ),
        ],
      ),
    );
  }
}
