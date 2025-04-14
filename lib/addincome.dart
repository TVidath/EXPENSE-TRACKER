import 'package:flutter/material.dart';
import 'package:expense_tracker/models/income.dart';
import 'package:expense_tracker/widgets/currency_converter.dart';
import 'package:expense_tracker/services/settings_service.dart';
import 'package:intl/intl.dart';

class AddIncome extends StatefulWidget {
  const AddIncome({super.key, required this.onAddIncome});

  final void Function(Income income) onAddIncome;

  @override
  State<AddIncome> createState() {
    return _AddIncomeState();
  }
}

class _AddIncomeState extends State<AddIncome> {
  final _titleController = TextEditingController();
  IncomeSource _selectedSource = IncomeSource.salary;
  DateTime? _selectedDate;
  double _enteredAmount = 0;
  String _selectedCurrency = '';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Get the current default currency
    final settings = SettingsService.getCurrentSettings();
    _selectedCurrency = settings.currencyCode;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _submitIncomeData() {
    // validate the form
    if (!_formKey.currentState!.validate()) {
      // Show validation errors
      return;
    }

    // validation for amount
    if (_enteredAmount <= 0) {
      // show error message
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid input'),
          content: const Text(
              'Please make sure a valid title, amount, date and source was entered.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Okay'),
            ),
          ],
        ),
      );
      return;
    }

    // validation for date
    if (_selectedDate == null) {
      // show error message
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No date selected'),
          content: const Text('Please select a date for the income.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Okay'),
            ),
          ],
        ),
      );
      return;
    }

    // Get current default currency
    final settings = SettingsService.getCurrentSettings();
    final defaultCurrency = settings.currencyCode;

    // Create new income
    Income newIncome;

    if (_selectedCurrency != defaultCurrency) {
      // If currency is not the default, save original currency and amount
      double originalAmount = _enteredAmount;

      // The converted amount is already stored in _enteredAmount from the CurrencyConverter callback
      newIncome = Income(
        title: _titleController.text,
        amount: _enteredAmount,
        date: _selectedDate!,
        source: _selectedSource,
        originalCurrency: _selectedCurrency,
        originalAmount: originalAmount,
      );
    } else {
      // If using default currency, no need to track original
      newIncome = Income(
        title: _titleController.text,
        amount: _enteredAmount,
        date: _selectedDate!,
        source: _selectedSource,
      );
    }

    // Call the callback function
    widget.onAddIncome(newIncome);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    final dateFormatter = DateFormat.yMd();

    return SizedBox(
      height: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  maxLength: 50,
                  decoration: const InputDecoration(
                    label: Text('Title'),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CurrencyConverter(
                  onAmountChanged: (amount) {
                    setState(() {
                      _enteredAmount = amount;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'No date selected'
                          : dateFormatter.format(_selectedDate!),
                    ),
                    IconButton(
                      onPressed: _presentDatePicker,
                      icon: const Icon(
                        Icons.calendar_month,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    DropdownButton(
                      value: _selectedSource,
                      items: IncomeSource.values
                          .map(
                            (source) => DropdownMenuItem(
                              value: source,
                              child: Text(
                                source.name.toUpperCase(),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _selectedSource = value;
                        });
                      },
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: _submitIncomeData,
                      child: const Text('Save Income'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
