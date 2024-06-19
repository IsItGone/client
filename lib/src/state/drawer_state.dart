import 'dart:developer';
import 'package:flutter/material.dart';

class DrawerState extends ChangeNotifier {
  bool _isDrawerOpen = false;
  double _drawerHeight = 300;
  final double minHeight;
  final double maxHeight;

  DrawerState({
    required this.minHeight,
    required this.maxHeight,
  });

  bool get isDrawerOpen => _isDrawerOpen;
  double get drawerHeight => _drawerHeight;

  void toggleDrawer() {
    _isDrawerOpen = !_isDrawerOpen;
    notifyListeners();
  }

  void openDrawer() {
    if (!_isDrawerOpen) {
      log('open drawer');
      _isDrawerOpen = true;
      notifyListeners();
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
