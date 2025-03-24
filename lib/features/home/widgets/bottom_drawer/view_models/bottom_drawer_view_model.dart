import 'dart:developer';
import 'package:client/features/home/widgets/bottom_drawer/models/info_type.dart';
import 'package:client/features/home/widgets/bottom_drawer/models/drawer_state.dart';
import 'package:client/features/home/widgets/map/providers/naver_map_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomDrawerViewModel extends ChangeNotifier {
  final Ref _ref;
  DrawerState _state;

  BottomDrawerViewModel(this._ref) : _state = const DrawerState();

  InfoType get infoType => _state.type;
  bool get isDrawerOpen => _state.isOpen;
  String get infoId => _state.infoId;

  void setAnimationController(AnimationController controller) {
    _state = _state.copyWith(animationController: controller);
  }

  Future<void> openDrawer(InfoType type) async {
    if (!_state.isOpen) {
      log('opening drawer with type: $type');
      _state = _state.copyWith(
        type: type,
        isOpen: true,
      );
      _state.animationController?.forward();
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));
    } else {
      updateInfoType(type);
    }
  }

  void closeDrawer() {
    if (_state.isOpen) {
      log('closing drawer');
      _state = _state.copyWith(isOpen: false);
      _state.animationController?.reverse();

      // 선택 상태 초기화
      _ref.read(naverMapViewModelProvider.notifier).resetSelection();
      notifyListeners();
    }
  }

  void updateInfoId(String id) {
    if (_state.infoId != id) {
      _state = _state.copyWith(infoId: id);
      notifyListeners();
    }
  }

  void updateInfoType(InfoType type) {
    if (_state.type != type) {
      _state = _state.copyWith(type: type);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _state.animationController?.dispose();
    super.dispose();
  }
}
