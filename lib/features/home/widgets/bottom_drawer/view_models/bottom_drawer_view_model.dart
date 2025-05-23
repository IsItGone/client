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
  String? get stationId => _state.stationId;
  String? get routeId => _state.routeId;

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
      updateInfoId(stationId: null, routeId: null);
      notifyListeners();
    }
  }

  void updateInfoId({String? stationId, String? routeId}) {
    log('updating infoId: stationId: $stationId, routeId: $routeId');
    if (_state.stationId != stationId) {
      _state = _state.copyWith(stationId: stationId);
      notifyListeners();
    }
    if (_state.routeId != routeId) {
      _state = _state.copyWith(routeId: routeId);
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
