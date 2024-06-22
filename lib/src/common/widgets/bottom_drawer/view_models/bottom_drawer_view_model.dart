import 'dart:developer';
import 'package:flutter/material.dart';

class BottomDrawerViewModel extends ChangeNotifier {
  bool _isDrawerOpen = true;
  double _drawerHeight = 400;
  final double minHeight;
  final double maxHeight;

  BottomDrawerViewModel({
    required this.minHeight,
    required this.maxHeight,
  });

  bool get isDrawerOpen => _isDrawerOpen;
  double get drawerHeight => _drawerHeight;

  void toggleDrawer() {
    _isDrawerOpen = !_isDrawerOpen;
    notifyListeners();
  }

  Future<void> openDrawer() async {
    if (!_isDrawerOpen) {
      log('open drawer');
      _isDrawerOpen = true;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  void closeDrawer() {
    log('close drawer');
    if (_isDrawerOpen) {
      _isDrawerOpen = false;
      notifyListeners();
    }
  }

  void setDrawerHeight(double height) {
    if (height < minHeight) {
      _drawerHeight = minHeight;
    } else if (height > maxHeight) {
      _drawerHeight = maxHeight;
    } else {
      _drawerHeight = height;
    }
    notifyListeners();
  }
}
