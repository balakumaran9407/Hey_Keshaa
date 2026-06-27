import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  bool _notificationsEnabled = true;
  bool _autoSaveEnabled = true;

  int get selectedIndex => _selectedIndex;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get autoSaveEnabled => _autoSaveEnabled;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }

  void toggleAutoSave() {
    _autoSaveEnabled = !_autoSaveEnabled;
    notifyListeners();
  }
}
