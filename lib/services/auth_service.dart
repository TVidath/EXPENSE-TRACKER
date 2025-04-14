import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/models/user.dart';

class AuthService {
  static const String _userKey = 'user';
  static ValueNotifier<User?> currentUserNotifier = ValueNotifier<User?>(null);

  // Check if user is logged in
  static bool get isLoggedIn => currentUserNotifier.value != null;

  // Get current user
  static User? get currentUser => currentUserNotifier.value;

  // Load user from persistent storage
  static Future<void> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final userData = jsonDecode(userJson);
        currentUserNotifier.value = User.fromJson(userData);
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  // Save user to persistent storage
  static Future<void> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      currentUserNotifier.value = user;
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  // Login with email and password
  static Future<bool> login(String email, String password) async {
    try {
      // In a real app, you would validate credentials against a server
      // This is a mock implementation for demonstration purposes

      // Simple validation
      if (email.isEmpty || !email.contains('@') || password.isEmpty) {
        return false;
      }

      // Mock successful login
      if (email == 'demo@example.com' && password == 'password') {
        final user = User(
          email: email,
          name: 'Demo User',
        );

        await saveUser(user);
        return true;
      }

      // Mock registration for new users
      if (password.length >= 6) {
        final user = User(
          email: email,
          name: email.split('@')[0], // Simple name extraction
        );

        await saveUser(user);
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error during login: $e');
      return false;
    }
  }

  // Logout user
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      currentUserNotifier.value = null;
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  // Update user profile
  static Future<void> updateProfile({
    String? name,
    String? photoUrl,
  }) async {
    try {
      if (currentUser == null) return;

      final updatedUser = currentUser!.copyWith(
        name: name,
        photoUrl: photoUrl,
      );

      await saveUser(updatedUser);
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
  }
}
