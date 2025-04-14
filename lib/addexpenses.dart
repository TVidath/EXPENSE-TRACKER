import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/currency_converter.dart';
import 'package:expense_tracker/services/settings_service.dart';
// import 'package:intl/intl.dart';//used to format the date and show in readable format

// final formatter = DateFormat.yMd();

class AddExpense extends StatefulWidget {
  const AddExpense({super.key, required this.onAddExpense});

  final void Function(Expense expense) onAddExpense;

  @override
  State<AddExpense> createState() {
    return _AddExpenseState();
  }
}

class _AddExpenseState extends State<AddExpense> {
  final _titleController = TextEditingController();
  Category _selectedCategory = Category.leisure;
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

  void _submitExpenseData() {
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
              'Please make sure a valid title, amount, date and category was entered.'),
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
          content: const Text('Please select a date for the expense.'),
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

    // Create new expense
    Expense newExpense;

    if (_selectedCurrency != defaultCurrency) {
      // If currency is not the default, save original currency and amount
      double originalAmount = _enteredAmount;

      // The converted amount is already stored in _enteredAmount from the CurrencyConverter callback
      newExpense = Expense(
        title: _titleController.text,
        amount: _enteredAmount,
        date: _selectedDate!,
        category: _selectedCategory,
        originalCurrency: _selectedCurrency,
        originalAmount: originalAmount,
      );
    } else {
      // If using default currency, no need to track original
      newExpense = Expense(
        title: _titleController.text,
        amount: _enteredAmount,
        date: _selectedDate!,
        category: _selectedCategory,
      );
    }

    // Call the callback function
    widget.onAddExpense(newExpense);
    Navigator.pop(context);
  }

  void _onAmountChanged(double amount, String currency) {
    setState(() {
      _enteredAmount = amount;
      _selectedCurrency = currency;
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
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
                          : formatter.format(_selectedDate!),
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
                      value: _selectedCategory,
                      items: Category.values
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(
                                category.name.toUpperCase(),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _selectedCategory = value;
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
                      onPressed: _submitExpenseData,
                      child: const Text('Save Expense'),
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
