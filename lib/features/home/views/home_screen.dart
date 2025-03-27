import 'dart:developer';
import 'dart:js_interop';

import 'package:client/core/constants/route_colors.dart';
import 'package:client/data/models/route_model.dart';
import 'package:client/features/home/widgets/bottom_drawer/bottom_drawer.dart';
import 'package:client/features/home/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/features/home/widgets/map/providers/naver_map_providers.dart';
import 'package:client/features/home/widgets/map/naver_map_widget.dart';
import 'package:client/data/providers/route_providers.dart';
import 'package:client/shared/widgets/map_search_bar.dart';
import 'package:client/shared/widgets/route_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

@JS('selectRoute')
external void selectRouteJS(String routeId);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawerState = ref.watch(bottomDrawerProvider);
    final routesAsync = ref.watch(RouteProviders.routesDataProvider);

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
                    child: SizedBox(
                      height: 50,
                      child: routesAsync.when(
                        data: (routes) {
                          return kIsWeb
                              ? PointerInterceptor(
                                  child: _buildRouteList(routes, ref),
                                )
                              : _buildRouteList(routes, ref);
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Text('에러 발생: $err'),
                      ),
                    ),
                  )
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

  Widget _buildRouteList(List<RouteModel> routes, WidgetRef ref) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: routes.length,
      itemBuilder: (context, index) {
        final route = routes[index];
        return Row(
          children: [
            RouteButton(
              isSelected: false,
              onPressed: () {
                ref
                    .read(naverMapViewModelProvider.notifier)
                    .onRouteSelected(route.id);
                if (kIsWeb) {
                  selectRouteJS(
                    route.id,
                  );
                }
              },
              text: route.name,
              size: ButtonSize.lg,
              color: RouteColors.getColor(route.id),
            ),
          ],
        );
      },
    );
  }
}
