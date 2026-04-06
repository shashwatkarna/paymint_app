import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';

/// User Profile Provider: Manages the current user's profile data from Firestore.
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
     return Stream.value(null);
  }
  return UserService().streamProfile(user.uid);
});

/// Theme Provider: Manages Light/Dark mode state.
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void toggle(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

/// Currency Provider: Manages preferred currency (Default: INR).
class CurrencyNotifier extends Notifier<String> {
  @override
  String build() => 'INR';

  void setCurrency(String newCurrency) {
    state = newCurrency;
  }
}

final currencyProvider = NotifierProvider<CurrencyNotifier, String>(CurrencyNotifier.new);
