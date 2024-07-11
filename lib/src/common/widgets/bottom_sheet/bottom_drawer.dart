// import 'package:client/src/common/widgets/bottom_sheet/view_models/bottom_drawer_view_model.dart';
// import 'package:client/src/config/theme.dart';
// import 'package:flutter/material.dart';

// class BottomDrawer extends StatefulWidget {
//   final BottomDrawerViewModel drawerState;
//   final BottomDrawerViewModel drawerNotifier;
//   final Widget child;

//   const BottomDrawer({
//     super.key,
//     required this.drawerState,
//     required this.drawerNotifier,
//     required this.child,
//   });

//   @override
//   State<StatefulWidget> createState() => _BottomDrawerState();
// }

// class _BottomDrawerState extends State<BottomDrawer>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//   double _dragStartY = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//     _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

//     widget.drawerNotifier.setAnimationController(_controller);

//     _controller.addStatusListener((status) {
//       if (status == AnimationStatus.dismissed) {
//         setState(() {});
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _onVerticalDragStart(DragStartDetails details) {
//     _dragStartY = details.localPosition.dy;
//   }

//   void _onVerticalDragUpdate(DragUpdateDetails details) {
//     final dragDistance = details.localPosition.dy - _dragStartY;
//     if (dragDistance > 100) {
//       widget.drawerNotifier.closeDrawer();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Visibility(
//         visible: widget.drawerState.isDrawerOpen ||
//             _controller.status == AnimationStatus.forward ||
//             _controller.status == AnimationStatus.reverse,
//         child: GestureDetector(
//           onVerticalDragStart: _onVerticalDragStart,
//           onVerticalDragUpdate: _onVerticalDragUpdate,
//           child: AnimatedBuilder(
//             animation: _animation,
//             child: widget.child,
//             builder: (context, child) {
//               return Container(
//                 height: MediaQuery.of(context).size.height *
//                     0.33 *
//                     _animation.value,
//                 color: Colors.transparent,
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: AppTheme.mainWhite,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(12),
//                       topRight: Radius.circular(12),
//                     ),
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: child!,
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class BottomDrawer extends StatelessWidget {
  const BottomDrawer({
    super.key,
    required this.isDrawerOpen,
    required this.child,
  });

  final bool isDrawerOpen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isDrawerOpen ? MediaQuery.of(context).size.height * 0.33 : 0,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: child,
    );
  }
}
