import 'package:flutter/material.dart';
import 'package:expense_tracker/models/budget.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/settings_service.dart';
import 'package:intl/intl.dart';

class BudgetList extends StatelessWidget {
  final List<Budget> budgets;
  final List<Expense> expenses;
  final Function(Budget) onRemoveBudget;

  const BudgetList({
    super.key,
    required this.budgets,
    required this.expenses,
    required this.onRemoveBudget,
  });

  @override
  Widget build(BuildContext context) {
    if (budgets.isEmpty) {
      return const Center(child: Text('No budgets found. Start adding some!'));
    }

    return ListView.builder(
      itemCount: budgets.length,
      itemBuilder: (ctx, index) => BudgetItem(
        budget: budgets[index],
        expenses: expenses,
        onRemove: onRemoveBudget,
      ),
    );
  }
}

class BudgetItem extends StatelessWidget {
  final Budget budget;
  final List<Expense> expenses;
  final Function(Budget) onRemove;

  const BudgetItem({
    super.key,
    required this.budget,
    required this.expenses,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat.yMd();
    final percentSpent = budget.calculatePercentSpent(expenses);
    final remaining = budget.calculateRemaining(expenses);
    final isExceeded = budget.isBudgetExceeded(expenses);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    budget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => onRemove(budget),
                  color: Colors.red,
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${budget.category.name.toUpperCase()} - ${budget.period.name.toUpperCase()}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  '${formatter.format(budget.startDate)} - ${formatter.format(budget.endDate)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget: ${SettingsService.formatCurrency(budget.amount)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Remaining: ${SettingsService.formatCurrency(remaining)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isExceeded ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentSpent / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                percentSpent > 90
                    ? Colors.red
                    : percentSpent > 75
                        ? Colors.orange
                        : Colors.green,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '${percentSpent.toStringAsFixed(1)}% used',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
