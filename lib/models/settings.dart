import 'package:flutter/material.dart';

class Settings {
  final String currencySymbol;
  final String currencyCode;
  final ThemeMode themeMode;
  final bool useSystemTheme;

  const Settings({
    this.currencySymbol = '\$',
    this.currencyCode = 'USD',
    this.themeMode = ThemeMode.system,
    this.useSystemTheme = true,
  });

  Settings copyWith({
    String? currencySymbol,
    String? currencyCode,
    ThemeMode? themeMode,
    bool? useSystemTheme,
  }) {
    return Settings(
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyCode: currencyCode ?? this.currencyCode,
      themeMode: themeMode ?? this.themeMode,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currencySymbol': currencySymbol,
      'currencyCode': currencyCode,
      'themeMode': themeMode.index,
      'useSystemTheme': useSystemTheme,
    };
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      currencySymbol: json['currencySymbol'] as String? ?? '\$',
      currencyCode: json['currencyCode'] as String? ?? 'USD',
      themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
      useSystemTheme: json['useSystemTheme'] as bool? ?? true,
    );
  }
}
