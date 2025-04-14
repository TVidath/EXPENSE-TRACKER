import 'package:flutter/material.dart';
import 'package:expense_tracker/income_item.dart';
import 'package:expense_tracker/models/income.dart';

class IncomesList extends StatelessWidget {
  const IncomesList({
    super.key,
    required this.incomes,
    required this.onRemoveIncome,
  });

  final List<Income> incomes;
  final void Function(Income income) onRemoveIncome;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: incomes.length,
      itemBuilder:
          (ctx, index) =>
              IncomeItem(incomes[index], onRemoveIncome: onRemoveIncome),
    );
  }
}
