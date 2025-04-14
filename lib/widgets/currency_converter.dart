import 'package:flutter/material.dart';
import 'package:expense_tracker/services/settings_service.dart';

class CurrencyConverter extends StatefulWidget {
  final Function(double) onAmountChanged;
  final String initialCurrency;
  final double initialAmount;

  const CurrencyConverter({
    Key? key,
    required this.onAmountChanged,
    this.initialCurrency = '',
    this.initialAmount = 0.0,
  }) : super(key: key);

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  late TextEditingController _amountController;
  late String _selectedCurrency;
  double _convertedAmount = 0.0;
  final bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    final settings = SettingsService.getCurrentSettings();
    _selectedCurrency = widget.initialCurrency.isNotEmpty
        ? widget.initialCurrency
        : settings.currencyCode;
    _amountController = TextEditingController(
        text: widget.initialAmount > 0
            ? widget.initialAmount.toStringAsFixed(2)
            : '');

    if (widget.initialAmount > 0) {
      _updateConvertedAmount();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updateConvertedAmount() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final settings = SettingsService.getCurrentSettings();

    if (_selectedCurrency == settings.currencyCode) {
      // No conversion needed if already in default currency
      _convertedAmount = amount;
    } else {
      // Convert from selected currency to default currency
      _convertedAmount =
          SettingsService.convertToDefaultCurrency(amount, _selectedCurrency);
    }

    // Notify parent with the converted amount
    widget.onAmountChanged(_convertedAmount);
  }

  @override
  Widget build(BuildContext context) {
    final currentSettings = SettingsService.getCurrentSettings();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText:
                      SettingsService.availableCurrencies[_selectedCurrency],
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _updateConvertedAmount();
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCurrency,
                items: SettingsService.availableCurrencies.keys.map((currency) {
                  return DropdownMenuItem<String>(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCurrency = value;
                      _updateConvertedAmount();
                    });
                  }
                },
              ),
            ),
          ],
        ),
        if (_selectedCurrency != currentSettings.currencyCode)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const Icon(
                  Icons.currency_exchange,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Converted: ${SettingsService.formatCurrency(_convertedAmount)}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
