import 'package:client/src/common/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/src/common/widgets/bottom_drawer/bottom_drawer.dart';
import 'package:client/src/common/widgets/map/components/app/naver_map_container.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NaverMapWidget extends ConsumerWidget {
  const NaverMapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawerState = ref.watch(bottomDrawerProvider);
    final drawerNotifier = ref.read(bottomDrawerProvider.notifier);

    return GestureDetector(
      onTap: () {
        if (drawerState.isDrawerOpen) {
          drawerState.closeDrawer();
        }
      },
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.only(
                bottom:
                    drawerState.isDrawerOpen ? drawerState.drawerHeight : 0),
            child: const NaverMapContainer(),
          ),
          BottomDrawer(
              drawerState: drawerState,
              drawerNotifier: drawerNotifier,
              child: const Type4()),
        ],
      ),
    );
  }
}

class Type4 extends StatefulWidget {
  const Type4({super.key});

  @override
  State<Type4> createState() => _Type4State();
}

class _Type4State extends State<Type4> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemBuilder: (context, index) {
          return Container(color: Colors.pink, child: subItem());
        },
      ),
    );
  }

  Widget subItem() {
    return InkWell(
      onTap: () {
        debugPrint('***** [JHC_DEBUG] 선택');
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
            ), // 좌측 차량 이미지
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('넥스트',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 4),
                        Icon(Icons.person, size: 14),
                        SizedBox(width: 4),
                        Text('5',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 4),
                        Icon(Icons.info_outline, size: 14),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      '대형 RV의 쾌적한 이동',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ), // 중간 차량 타입
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(Icons.arrow_upward,
                        size: 12, color: Colors.grey.withOpacity(0.8)),
                    Text('2.0배',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.withOpacity(0.8))),
                  ],
                ),
                const SizedBox(height: 2),
                const Text('예상 17,200원', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 2),
                Text(
                  '예상 23,200원',
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                    fontSize: 14,
                    color: Colors.grey.withOpacity(0.8),
                  ),
                ),
              ],
            ) // 오른쪽의 요금
          ],
        ),
      ),
    );
  }
}
