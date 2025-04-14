import 'package:flutter/material.dart';
import 'package:expense_tracker/models/settings.dart';
import 'package:expense_tracker/services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Settings _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsService.loadSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  void _updateCurrency(String? currencyCode) async {
    if (currencyCode != null) {
      await SettingsService.updateCurrency(currencyCode);
      setState(() {
        _settings = SettingsService.getCurrentSettings();
      });
      // Show confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Currency updated to $currencyCode'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _updateThemeMode(ThemeMode? themeMode) async {
    if (themeMode != null) {
      await SettingsService.updateThemeMode(themeMode);
      setState(() {
        _settings = SettingsService.getCurrentSettings();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Currency',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select your preferred currency:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _settings.currencyCode,
                      isExpanded: true,
                      items: SettingsService.availableCurrencies.entries
                          .map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text('${entry.key} (${entry.value})'),
                        );
                      }).toList(),
                      onChanged: _updateCurrency,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Current format:'),
                        const SizedBox(width: 8),
                        Text(
                          SettingsService.formatCurrency(1234.56),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Theme',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose app theme:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    RadioListTile<ThemeMode>(
                      title: const Text('System'),
                      value: ThemeMode.system,
                      groupValue: _settings.themeMode,
                      onChanged: _updateThemeMode,
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('Light'),
                      value: ThemeMode.light,
                      groupValue: _settings.themeMode,
                      onChanged: _updateThemeMode,
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('Dark'),
                      value: ThemeMode.dark,
                      groupValue: _settings.themeMode,
                      onChanged: _updateThemeMode,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expense Tracker',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Version 1.0.0'),
                    SizedBox(height: 16),
                    Text(
                      'A comprehensive app to track your expenses and incomes, manage budgets, and view financial reports.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
