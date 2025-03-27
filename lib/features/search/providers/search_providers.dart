import 'package:client/data/models/station_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 검색 결과를 저장할 StateProvider
final searchResultsProvider = StateProvider<List<StationModel>>((ref) => []);

// 검색어 상태를 저장할 StateProvider
final searchKeywordProvider = StateProvider<String>((ref) => '');
