import 'dart:developer';
import 'package:client/core/constants/route_colors.dart';
import 'package:client/data/models/route_model.dart';
import 'package:client/data/models/station_model.dart';
import 'package:client/data/providers/station_providers.dart';
import 'package:client/features/home/widgets/bottom_drawer/bottom_drawer.dart';
import 'package:client/features/home/widgets/bottom_drawer/providers/bottom_drawer_provider.dart';
import 'package:client/features/home/widgets/map/providers/naver_map_providers.dart';
import 'package:client/features/home/widgets/map/naver_map_widget.dart'
    deferred as mapwidget;
import 'package:client/data/providers/route_providers.dart';
import 'package:client/features/home/widgets/search_bar_button.dart';
import 'package:client/shared/widgets/route_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
  bool _isLoading = true;
  late Future<void> _mapLibraryFuture;

  List<RouteModel> _routes = [];
  List<StationModel> _stations = [];

  @override
  void initState() {
    super.initState();
    _mapLibraryFuture = mapwidget.loadLibrary();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final routeModels =
          await ref.read(RouteProviders.routesDataProvider.future);
      final stationModels =
          await ref.read(StationProviders.stationDataProvider.future);

      setState(() {
        _routes = routeModels;
        _stations = stationModels;
        _isLoading = false;
      });
    } catch (e) {
      log('데이터 로딩 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isDrawerOpen =
        ref.watch(bottomDrawerProvider.select((s) => s.isDrawerOpen));
    final routesAsync = ref.watch(RouteProviders.routesDataProvider);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final mapHeight = isDrawerOpen ? screenHeight * (1 - 0.33) : screenHeight;

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
            // child: NaverMapWidget(
            //   routes: _routes,
            //   stations: _stations,
            // ),

            child: FutureBuilder(
              future: _mapLibraryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return mapwidget.NaverMapWidget(
                    routes: _routes,
                    stations: _stations,
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),

          /// 상단 UI
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                            child: const Icon(Icons.arrow_back_ios_new_rounded),
                          ),
                        )
                      : const SearchBarButton(),
                  const SizedBox(height: 10),
                  if (!isDrawerOpen)
                    SizedBox(
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
                        error: (err, stack) => Text('에러 발생: $err',
                            style: TextStyle(color: Colors.red)),
                      ),
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
