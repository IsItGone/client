import 'dart:developer';
import 'package:client/core/constants/route_colors.dart';
import 'package:client/data/models/route_model.dart';
import 'package:client/features/home/widgets/bottom_drawer/bottom_drawer.dart';
import 'package:client/features/home/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/features/home/widgets/map/providers/naver_map_providers.dart';
import 'package:client/features/home/widgets/map/naver_map_widget.dart';
import 'package:client/data/providers/route_providers.dart';
import 'package:client/features/home/widgets/search_bar_button.dart';
import 'package:client/shared/widgets/route_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:client/features/home/widgets/map/widgets/web/naver_map_js_interop_stub.dart'
    if (dart.library.js_interop) 'package:client/features/home/widgets/map/widgets/web/naver_map_js_interop_web.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
  });
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    log('isWeb : $kIsWeb');
  }

  @override
  Widget build(BuildContext context) {
    final isDrawerOpen =
        ref.watch(bottomDrawerProvider.select((s) => s.isDrawerOpen));
    final routesAsync = ref.watch(RouteProviders.routesDataProvider);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      body: Stack(
        children: [
          RepaintBoundary(
            child: SizedBox(
              height: isDrawerOpen ? screenHeight * (1 - 0.33) : screenHeight,
              child: const NaverMapWidget(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: isDrawerOpen
                      ? Align(
                          alignment: Alignment.bottomLeft,
                          child: FloatingActionButton(
                            onPressed: () => ref
                                .read(bottomDrawerProvider.notifier)
                                .closeDrawer(),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                            ),
                          ),
                        )
                      : const SearchBarButton(),
                ),
                if (!isDrawerOpen)
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
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (err, stack) => Text('에러 발생: $err'),
                      ),
                    ),
                  )
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: kIsWeb
                ? PointerInterceptor(
                    child: const BottomDrawer(),
                  )
                : const BottomDrawer(),
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
