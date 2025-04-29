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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:client/features/home/widgets/map/widgets/web/js_interop_stub.dart'
    if (dart.library.js_interop) 'package:client/features/home/widgets/map/widgets/web/js_interop_web.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final mapAsync = ref.watch(RouteProviders.mapDataProvider);
    final isDrawerOpen =
        ref.watch(bottomDrawerProvider.select((s) => s.isDrawerOpen));
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final mapHeight = isDrawerOpen ? screenHeight * (1 - 0.33) : screenHeight;

    return mapAsync.when(
        loading: () => Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
        error: (e, _) => Scaffold(
              body: Center(child: Text('에러: $e')),
            ),
        data: (m) {
          return Scaffold(
            body: Stack(
              children: [
                /// 지도 영역
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  top: 0,
                  left: 0,
                  right: 0,
                  height: mapHeight,
                  child: NaverMapWidget(routes: m.routes, stations: m.stations),
                ),

                /// 상단 UI
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isDrawerOpen
                            ? Align(
                                alignment: Alignment.bottomLeft,
                                child: FloatingActionButton(
                                  onPressed: () => ref
                                      .read(bottomDrawerProvider.notifier)
                                      .closeDrawer(),
                                  child: const Icon(
                                      Icons.arrow_back_ios_new_rounded),
                                ),
                              )
                            : const SearchBarButton(),
                        const SizedBox(height: 10),
                        if (!isDrawerOpen)
                          SizedBox(
                            height: 50,
                            child: kIsWeb
                                ? PointerInterceptor(
                                    child: _buildRouteList(m.routes, ref),
                                  )
                                : _buildRouteList(m.routes, ref),
                          ),
                      ],
                    ),
                  ),
                ),

                /// 하단 드로어
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: kIsWeb
                      ? PointerInterceptor(child: BottomDrawer())
                      : const BottomDrawer(),
                ),
              ],
            ),
          );
        });
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
