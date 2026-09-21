import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode mode = ThemeMode.light;

  void toggle(bool dark) {
    mode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
