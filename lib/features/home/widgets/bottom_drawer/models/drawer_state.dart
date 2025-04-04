import 'package:flutter/material.dart';
import 'info_type.dart';

class DrawerState {
  final String? stationId;
  final String? routeId;
  final bool isOpen;
  final InfoType type;
  final AnimationController? animationController;

  const DrawerState({
    this.stationId,
    this.routeId,
    this.isOpen = false,
    this.type = InfoType.station,
    this.animationController,
  });

  DrawerState copyWith({
    String? stationId,
    String? routeId,
    bool? isOpen,
    InfoType? type,
    AnimationController? animationController,
  }) {
    return DrawerState(
      stationId: stationId ?? this.stationId,
      routeId: routeId ?? this.routeId,
      isOpen: isOpen ?? this.isOpen,
      type: type ?? this.type,
      animationController: animationController ?? this.animationController,
    );
  }
}
