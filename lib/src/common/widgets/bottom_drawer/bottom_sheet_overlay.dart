import 'dart:developer';
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
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  late String stationId;

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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 200,
      child: Column(
        children: [
          Text('Station ID: $stationId'),
          ListTile(
            title: const Text('Item 1'),
            onTap: () {
              log('Item 1 clicked');
            },
          ),
          ListTile(
            title: const Text('Item 2'),
            onTap: () {
              log('Item 2 clicked');
            },
          ),
          ListTile(
            title: const Text('Close'),
            onTap: widget.closeDrawer,
          ),
        ],
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
          child: kIsWeb
              ? PointerInterceptor(
                  child: BottomSheetContent(
                      stationId: stationId, closeDrawer: closeDrawer))
              : BottomSheetContent(
                  stationId: stationId, closeDrawer: closeDrawer),
        ),
      ),
    ),
  );
}
