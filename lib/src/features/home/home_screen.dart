import 'dart:developer';

import 'package:client/src/common/widgets/bottom_drawer/bottom_drawer.dart';
import 'package:client/src/common/widgets/bottom_drawer/models/info_type.dart';
import 'package:client/src/common/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/src/common/widgets/map/providers/naver_map_providers.dart';
import 'package:client/src/common/widgets/map_search_bar/map_search_bar.dart';
import 'package:client/src/common/widgets/route_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:client/src/common/widgets/map/views/naver_map_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pointer_interceptor/pointer_interceptor.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawerState = ref.watch(bottomDrawerProvider);
    final drawerNotifier = ref.read(bottomDrawerProvider.notifier);

    log('isWeb : $kIsWeb');
    return Scaffold(
      body: Stack(
        children: [
          const NaverMapWidget(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: drawerState.isDrawerOpen
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: FloatingActionButton(
                            onPressed: () => drawerState.closeDrawer(),
                            child: const Icon(Icons.arrow_back_ios_new_rounded),
                          ),
                        )
                      : const MapSearchBar(),
                ),
                if (!drawerState.isDrawerOpen)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          ...List.generate(
                            6,
                            (index) {
                              return RouteButton(
                                index: index + 1,
                                isSelected: false,
                                onPressed: () {
                                  final mapViewModel = ref
                                      .read(naverMapViewModelProvider.notifier);
                                  mapViewModel
                                      .selectRoute((index + 1).toString());
                                  drawerNotifier
                                      .updateInfoId((index + 1).toString());
                                  drawerNotifier.openDrawer(InfoType.route);
                                },
                                text: "${index + 1}호차",
                                size: ButtonSize.lg,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: drawerState.isDrawerOpen
                ? 0
                : -MediaQuery.of(context).size.height * 0.33,
            left: 0,
            right: 0,
            child: kIsWeb
                ? PointerInterceptor(
                    child: const SingleChildScrollView(
                      child: BottomDrawer(),
                    ),
                  )
                : const SingleChildScrollView(
                    child: BottomDrawer(),
                  ),
          ),
        ],
      ),
    );
  }
}
