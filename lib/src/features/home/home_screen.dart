import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:client/src/common/widgets/map/views/naver_map_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    log('isWeb : $kIsWeb');
    return const Scaffold(
      body: NaverMapWidget(),
    );
  }
}
