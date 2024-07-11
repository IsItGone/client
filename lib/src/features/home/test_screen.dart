
// import 'package:client/src/common/widgets/bottom_sheet/bottom_drawer.dart';
// import 'package:client/src/common/widgets/bottom_sheet/components/station_detail.dart';
// import 'package:client/src/common/widgets/bottom_sheet/providers/bottom_drawer_provider.dart';
// import 'package:client/src/common/widgets/map/views/components/app/naver_map_container.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class TestScreen extends ConsumerWidget {
//   const TestScreen({super.key});

//   // bool _isOverlayOpen = false;
//   // late Animation<Offset> _offsetAnimation;
//   // late AnimationController _animationController;

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   ref
//   //       .read(bottomSheetProvider.notifier)
//   //       .setAnimationController(_animationController);
//   //   // _offsetAnimation = ref.read(bottomSheetProvider.notifier)._offsetAnimation;
//   //   ref.read(bottomSheetProvider.notifier).addListener(_handleOverlayChange);
//   // }

//   // @override
//   // void dispose() {
//   //   ref.read(bottomSheetProvider.notifier).removeListener(_handleOverlayChange);
//   //   super.dispose();
//   // }

//   // void _handleOverlayChange() {
//   //   final notifier = ref.read(bottomSheetProvider.notifier);
//   //   if (_isOverlayOpen != notifier.isOverlayOpen) {
//   //     setState(() {
//   //       _isOverlayOpen = notifier.isOverlayOpen;
//   //     });
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final drawerState = ref.watch(bottomDrawerProvider);
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('naver Maps with Markers'),
//         ),
//         body: Stack(
//           children: [
//             const Stack(
//               children: <Widget>[
//                 NaverMapContainer(),
//               ],
//             ),
//             BottomDrawer(
//               isOverlayOpen: drawerState.isDrawerOpen,
//               child: const StationDetail(""),
//             ),
//           ],
//         ));
//   }
// }
