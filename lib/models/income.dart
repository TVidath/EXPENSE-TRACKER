import 'package:uuid/uuid.dart';

enum IncomeSource { salary, business, investment, other }

class Income {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final IncomeSource source;

  Income({
    String? id,
    required this.title,
    required this.amount,
    required this.date,
    required this.source,
  }) : id = id ?? const Uuid().v4();
}
