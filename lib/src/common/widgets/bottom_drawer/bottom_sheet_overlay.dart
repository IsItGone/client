import 'dart:developer';
import 'package:client/src/common/widgets/bottom_drawer/components/station_detail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class BottomSheetContent extends StatefulWidget {
  final String stationId;
  final VoidCallback closeDrawer;

  const BottomSheetContent({
    super.key,
    required this.stationId,
    required this.closeDrawer,
  });

  @override
  State<StatefulWidget> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  late String stationId;
  double _dragStartY = 0.0;

  @override
  void initState() {
    super.initState();
    stationId = widget.stationId;
  }

  @override
  void didUpdateWidget(covariant BottomSheetContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stationId != widget.stationId) {
      setState(() {
        stationId = widget.stationId;
      });
    }
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _dragStartY = details.localPosition.dy;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final dragDistance = details.localPosition.dy - _dragStartY;
    if (dragDistance > 100) {
      widget.closeDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      child: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height * 0.33,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: StationDetail(widget.stationId),
            ),
          ],
        ),
      ),
    );
  }
}

OverlayEntry createBottomSheetOverlay(
    BuildContext context,
    Animation<Offset> offsetAnimation,
    VoidCallback closeDrawer,
    String stationId) {
  return OverlayEntry(
    builder: (context) => Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: offsetAnimation,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            child: kIsWeb
                ? PointerInterceptor(
                    child: BottomSheetContent(
                        stationId: stationId, closeDrawer: closeDrawer))
                : BottomSheetContent(
                    stationId: stationId, closeDrawer: closeDrawer),
          ),
        ),
      ),
    ),
  );
}
