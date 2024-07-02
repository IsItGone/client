import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:client/src/common/widgets/bottom_drawer/bottom_sheet_overlay.dart';

class BottomSheetViewModel extends ChangeNotifier {
  String _stationId = "";
  bool _isDrawerOpen = false;
  AnimationController? _animationController;
  OverlayEntry? _overlayEntry;
  late Animation<Offset> _offsetAnimation;

  bool get isDrawerOpen => _isDrawerOpen;
  String get stationId => _stationId;

  void setAnimationController(AnimationController controller) {
    _animationController = controller;
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> openDrawer(BuildContext context, String stationId) async {
    _stationId = stationId;
    if (_isDrawerOpen) {
      _updateOverlay(context, stationId);
      return;
    }

    log('open drawer');
    _isDrawerOpen = true;
    _showOverlayBottomSheet(context);
    await _animationController?.forward();
    notifyListeners();
  }

  void closeDrawer() {
    log('close drawer');
    if (_isDrawerOpen) {
      _isDrawerOpen = false;
      _animationController?.reverse().then((_) {
        _removeOverlay();
      });
      notifyListeners();
    }
  }

  void _showOverlayBottomSheet(BuildContext context) {
    if (_overlayEntry != null) return;

    _overlayEntry = _createOverlayEntry(context);
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _updateOverlay(BuildContext context, String stationId) {
    _stationId = stationId;
    _removeOverlay();
    _showOverlayBottomSheet(context);
    notifyListeners();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    return createBottomSheetOverlay(
      context,
      _offsetAnimation,
      closeDrawer,
      _stationId,
    );
  }
}
