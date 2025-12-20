import 'package:flutter/material.dart';
import 'package:beacon/main.dart';

class FakeMyAppState extends ChangeNotifier implements MyAppState {
  bool _isDarkMode = false;
  final List<String> _predefinedMessages = ["HELP", "LOCATION", "MEDICAL"];

  @override
  ThemeMode get themeMode =>
      _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  @override
  bool get isDarkMode => _isDarkMode;

  @override
  List<String> get predefinedMessages => _predefinedMessages;

  @override
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  @override
  Future<void> addPredefinedMessage(String message) async {
    if (message.isEmpty) return;
    if (_predefinedMessages.contains(message)) return;
    _predefinedMessages.add(message);
    notifyListeners();
  }

  @override
  Future<void> deletePredefinedMessage(String message) async {
    _predefinedMessages.remove(message);
    notifyListeners();
  }
}
