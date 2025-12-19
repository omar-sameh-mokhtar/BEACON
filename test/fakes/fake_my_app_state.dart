import 'package:flutter/material.dart';
import 'package:beacon/main.dart';

class FakeMyAppState extends ChangeNotifier implements MyAppState {
  @override
  bool isDarkMode = false;

  @override
  ThemeMode get themeMode =>
      isDarkMode ? ThemeMode.dark : ThemeMode.light;

  @override
  Future<void> toggleTheme() async {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}
