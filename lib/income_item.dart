import 'package:flutter/material.dart';
import 'package:expense_tracker/models/income.dart';
import 'package:expense_tracker/services/settings_service.dart';
import 'package:intl/intl.dart';

class IncomeItem extends StatelessWidget {
  const IncomeItem(
    this.income, {
    super.key,
    required this.onRemoveIncome,
  });

  final Income income;
  final void Function(Income income) onRemoveIncome;

  IconData _getIconForSource(IncomeSource source) {
    switch (source) {
      case IncomeSource.salary:
        return Icons.work;
      case IncomeSource.business:
        return Icons.business;
      case IncomeSource.investment:
        return Icons.trending_up;
      case IncomeSource.other:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              income.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  SettingsService.formatCurrency(income.amount),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (income.wasConverted)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Tooltip(
                      message:
                          'Originally ${SettingsService.formatCurrencyWithCode(income.originalAmount!, income.originalCurrency!)}',
                      child: const Icon(
                        Icons.currency_exchange,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                const Spacer(),
                Row(
                  children: [
                    Icon(_getIconForSource(income.source), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      income.source.name.toUpperCase(),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat.yMd().format(income.date),
                      style: const TextStyle(fontSize: 12),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        onRemoveIncome(income);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
