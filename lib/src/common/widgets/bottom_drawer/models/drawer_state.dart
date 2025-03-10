import 'package:flutter/material.dart';
import 'info_type.dart';

class DrawerState {
  final String infoId;
  final bool isOpen;
  final InfoType type;
  final AnimationController? animationController;

  const DrawerState({
    this.infoId = "",
    this.isOpen = false,
    this.type = InfoType.station,
    this.animationController,
  });

  DrawerState copyWith({
    String? infoId,
    bool? isOpen,
    InfoType? type,
    AnimationController? animationController,
  }) {
    return DrawerState(
      infoId: infoId ?? this.infoId,
      isOpen: isOpen ?? this.isOpen,
      type: type ?? this.type,
      animationController: animationController ?? this.animationController,
    );
  }
}
