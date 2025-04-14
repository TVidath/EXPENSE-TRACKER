import 'package:expense_tracker/expenses.dart';
import 'package:expense_tracker/models/settings.dart';
import 'package:expense_tracker/screens/login_screen.dart';
import 'package:expense_tracker/services/auth_service.dart';
import 'package:expense_tracker/services/settings_service.dart';
import 'package:flutter/material.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load settings at app startup
  await SettingsService.loadSettings();

  // Load user data
  await AuthService.loadUser();

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    // Listen for settings changes to update the app
    SettingsService.settingsNotifier.addListener(_applySettings);
    // Listen for auth changes
    AuthService.currentUserNotifier.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    SettingsService.settingsNotifier.removeListener(_applySettings);
    AuthService.currentUserNotifier.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _applySettings() {
    setState(() {
      // This will trigger a rebuild with new settings
    });
  }

  void _onAuthChanged() {
    setState(() {
      // This will trigger a rebuild when auth state changes
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService.getCurrentSettings();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 96, 59, 181),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color.fromARGB(255, 96, 59, 181),
        ),
      ),
      home: AuthService.isLoggedIn ? const Expenses() : const LoginScreen(),
    );
  }
}
