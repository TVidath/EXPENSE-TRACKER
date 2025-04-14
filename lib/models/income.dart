import 'package:uuid/uuid.dart';

enum IncomeSource { salary, business, investment, other }

class Income {
  final String id;
  final String title;
  final double amount; // Amount in default currency
  final DateTime date;
  final IncomeSource source;
  final String?
      originalCurrency; // Original currency code if different from default
  final double? originalAmount; // Original amount before conversion

  Income({
    String? id,
    required this.title,
    required this.amount,
    required this.date,
    required this.source,
    this.originalCurrency,
    this.originalAmount,
  }) : id = id ?? const Uuid().v4();

  // Checks if this income was created in a currency other than the default
  bool get wasConverted {
    return originalCurrency != null && originalAmount != null;
  }

  // Factory to create a copy with updated values
  Income copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    IncomeSource? source,
    String? originalCurrency,
    double? originalAmount,
  }) {
    return Income(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      source: source ?? this.source,
      originalCurrency: originalCurrency ?? this.originalCurrency,
      originalAmount: originalAmount ?? this.originalAmount,
    );
  }
}
