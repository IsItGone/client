import 'dart:developer';
import 'package:flutter/material.dart';

class BottomDrawerViewModel extends ChangeNotifier {
  String _stationId = "";
  bool _isDrawerOpen = false;
  AnimationController? _animationController;

  bool get isDrawerOpen => _isDrawerOpen;
  String get stationId => _stationId;

  // void toggleDrawer() {
  //   _isDrawerOpen = !_isDrawerOpen;
  //   notifyListeners();
  // }

  Future<void> openDrawer() async {
    if (!_isDrawerOpen) {
      log('open drawer');
      _isDrawerOpen = true;
      _animationController?.forward();
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  void closeDrawer() {
    log('close drawer');
    if (_isDrawerOpen) {
      _isDrawerOpen = false;
      _animationController?.reverse();
      notifyListeners();
    }
  }

  void updateStationId(String stationId) {
    _stationId = stationId;
    notifyListeners();
  }
}
