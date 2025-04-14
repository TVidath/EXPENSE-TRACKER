import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/models/settings.dart';
import 'package:expense_tracker/services/data_persistence.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';
  static Settings _cachedSettings = const Settings();
  static final ValueNotifier<Settings> settingsNotifier =
      ValueNotifier<Settings>(_cachedSettings);

  // Currency options for the app
  static const Map<String, String> availableCurrencies = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'INR': '₹',
    'CNY': '¥',
    'RUB': '₽',
    'BRL': 'R\$',
    'CAD': 'C\$',
    'AUD': 'A\$',
  };

  // Exchange rates relative to USD (as of mid-2023)
  // These would ideally come from an API in a production app
  static const Map<String, double> _exchangeRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.78,
    'JPY': 143.50,
    'INR': 83.14,
    'CNY': 7.21,
    'RUB': 91.34,
    'BRL': 4.91,
    'CAD': 1.35,
    'AUD': 1.52,
  };

  // Save settings to persistent storage
  static Future<void> saveSettings(Settings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
      _cachedSettings = settings;
      settingsNotifier.value = settings;
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  // Load settings from persistent storage
  static Future<Settings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      if (settingsJson == null) {
        return _cachedSettings;
      }

      final settings = Settings.fromJson(jsonDecode(settingsJson));
      _cachedSettings = settings;
      settingsNotifier.value = settings;
      return settings;
    } catch (e) {
      debugPrint('Error loading settings: $e');
      return _cachedSettings;
    }
  }

  // Update currency settings
  static Future<void> updateCurrency(String currencyCode) async {
    final symbol = availableCurrencies[currencyCode] ?? '\$';
    final oldCurrencyCode = _cachedSettings.currencyCode;

    // Only proceed with conversion if currency actually changed
    if (oldCurrencyCode != currencyCode) {
      // Create updated settings
      final updatedSettings = _cachedSettings.copyWith(
        currencyCode: currencyCode,
        currencySymbol: symbol,
      );

      // Save the new settings
      await saveSettings(updatedSettings);

      // Convert all saved expenses and incomes to the new currency
      await DataPersistence.convertAllAmountsToNewCurrency(
          oldCurrencyCode, currencyCode);
    }
  }

  // Format currency with current settings
  static String formatCurrency(double amount) {
    // Load cached settings for quick formatting
    return '${_cachedSettings.currencySymbol}${amount.toStringAsFixed(2)}';
  }

  // Format currency with a specific currency code
  static String formatCurrencyWithCode(double amount, String currencyCode) {
    final symbol = availableCurrencies[currencyCode] ?? '\$';
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  // Update theme settings
  static Future<void> updateThemeMode(ThemeMode themeMode) async {
    final updatedSettings = _cachedSettings.copyWith(
      themeMode: themeMode,
      useSystemTheme: themeMode == ThemeMode.system,
    );
    await saveSettings(updatedSettings);
  }

  // Get current settings without loading from storage
  static Settings getCurrentSettings() {
    return _cachedSettings;
  }

  // Convert amount from one currency to another
  static double convertCurrency(
      double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return amount;

    // Convert to USD first (base currency)
    final amountInUSD = amount / _exchangeRates[fromCurrency]!;

    // Then convert from USD to target currency
    return amountInUSD * _exchangeRates[toCurrency]!;
  }

  // Convert amount from specified currency to the default currency
  static double convertToDefaultCurrency(double amount, String fromCurrency) {
    return convertCurrency(amount, fromCurrency, _cachedSettings.currencyCode);
  }

  // Convert amount from default currency to specified currency
  static double convertFromDefaultCurrency(double amount, String toCurrency) {
    return convertCurrency(amount, _cachedSettings.currencyCode, toCurrency);
  }
}
