import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

const uuid = Uuid();
final formatter = DateFormat.yMd();

enum Category { food, travel, leisure, work }

const categoryIcons = {
  Category.food: Icons.restaurant,
  Category.travel: Icons.airplanemode_active,
  Category.leisure: Icons.movie,
  Category.work: Icons.work,
};

class Expense {
  Expense({
    String? id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    String? originalCurrency,
    double? originalAmount,
  })  : id = id ?? uuid.v4(),
        originalCurrency = originalCurrency,
        originalAmount = originalAmount;

  final String id;
  final String title;
  final double amount; // Amount in default currency
  final DateTime date;
  final Category category;
  final String?
      originalCurrency; // Original currency code if different from default
  final double? originalAmount; // Original amount before conversion

  String get formattedDate {
    return formatter.format(date);
  }

  // Checks if this expense was created in a currency other than the default
  bool get wasConverted {
    return originalCurrency != null && originalAmount != null;
  }

  // Factory to create a copy with updated values
  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    Category? category,
    String? originalCurrency,
    double? originalAmount,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      originalCurrency: originalCurrency ?? this.originalCurrency,
      originalAmount: originalAmount ?? this.originalAmount,
    );
  }
}
