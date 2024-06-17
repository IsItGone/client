import 'package:client/src/config/theme.dart';
import 'package:flutter/material.dart';

class ModalBottomSheet extends StatelessWidget {
  final String markerId;

  const ModalBottomSheet({super.key, required this.markerId});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.mainWhite,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Marker ID: $markerId'),
            ElevatedButton(
              child: const Text('Done!'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
    );
  }
}

void displayStationInfo(BuildContext context, String markerId) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.25,
        maxChildSize: 0.85,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Container(
              height: 1500,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  color: AppTheme.mainWhite),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Marker ID: $markerId'),
                    ElevatedButton(
                      child: const Text('Done!'),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
