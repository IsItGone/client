import 'dart:developer';
import 'package:client/src/common/widgets/map/view_models/naver_map_view_model.dart';
import 'package:flutter/material.dart';

enum InfoType { place, station, route }

class BottomDrawerViewModel extends ChangeNotifier {
  String _infoId = "";
  bool _isDrawerOpen = false;
  InfoType _infoType = InfoType.station;
  AnimationController? _animationController;

  InfoType get infoType => _infoType;
  bool get isDrawerOpen => _isDrawerOpen;
  String get infoId => _infoId;

  // void toggleDrawer() {
  //   _isDrawerOpen = !_isDrawerOpen;
  //   notifyListeners();
  // }

  Future<void> openDrawer(InfoType infoType) async {
    if (!_isDrawerOpen) {
      log('open drawer');
      _infoType = infoType;
      _isDrawerOpen = true;
      _animationController?.forward();
      notifyListeners();
      await Future.delayed(
        const Duration(milliseconds: 300),
      );
    } else {
      updateInfoType(infoType);
    }
  }

  void closeDrawer() {
    log('close drawer');
    if (_isDrawerOpen) {
      _isDrawerOpen = false;
      _animationController?.reverse();
      notifyListeners();
      ShuttleDataLoader.resetOverlayVisibility();
    }
  }

  void updateInfoId(String infoId) {
    _infoId = infoId;
    notifyListeners();
  }

  void updateInfoType(InfoType infoType) {
    if (_infoType != infoType) {
      _infoType = infoType;
      notifyListeners();
    }
  }
}
