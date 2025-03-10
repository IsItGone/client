import 'package:flutter_naver_map/flutter_naver_map.dart';

class MapState {
  final Map<String, Map<String, NMultipartPathOverlay>> routeOverlays;
  final Set<NAddableOverlay<NOverlay<void>>> baseStations;
  final Set<NAddableOverlay<NOverlay<void>>> extendedStations;
  final String? selectedRouteId;
  final NaverMapController? mapController;
  final double currentZoom;

  const MapState({
    this.routeOverlays = const {},
    this.baseStations = const {},
    this.extendedStations = const {},
    this.selectedRouteId,
    this.mapController,
    this.currentZoom = 0,
  });

  bool get isExtendedView => currentZoom >= 14;

  MapState copyWith({
    Map<String, Map<String, NMultipartPathOverlay>>? routeOverlays,
    Set<NAddableOverlay<NOverlay<void>>>? baseStations,
    Set<NAddableOverlay<NOverlay<void>>>? extendedStations,
    String? selectedRouteId,
    NaverMapController? mapController,
    double? currentZoom,
  }) {
    return MapState(
      routeOverlays: routeOverlays ?? this.routeOverlays,
      baseStations: baseStations ?? this.baseStations,
      extendedStations: extendedStations ?? this.extendedStations,
      selectedRouteId: selectedRouteId ?? this.selectedRouteId,
      mapController: mapController ?? this.mapController,
      currentZoom: currentZoom ?? this.currentZoom,
    );
  }
}
