import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final naverMapClientIdProvider = Provider<String>((ref) {
  const naverMapClientId = String.fromEnvironment('NAVER_MAP_CLIENT_ID');
  log('naver map client id : $naverMapClientId');
  return naverMapClientId;
});
