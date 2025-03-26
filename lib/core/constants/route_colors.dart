import 'package:client/core/theme/theme.dart';
import 'package:flutter/material.dart';

class RouteColors {
  static final Map<String, Color> _routeColorMap = {};
  static final List<Color> _defaultColors = AppTheme.lineColors;

  static void initializeColors(List<String> routeIds) {
    for (int i = 0; i < routeIds.length; i++) {
      if (!_routeColorMap.containsKey(routeIds[i])) {
        _routeColorMap[routeIds[i]] =
            // TODO: +1 제거?
            _defaultColors[i % _defaultColors.length + 1];
      }
    }
  }

  static Color getColor(String routeId) {
    return _routeColorMap[routeId] ?? AppTheme.primarySwatch;
  }

  static Map<String, Color> get routeColorMap => _routeColorMap;
}
