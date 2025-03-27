import 'package:client/features/search/providers/search_providers.dart';
import 'package:client/features/search/widgets/station_search_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchResult extends ConsumerWidget {
  const SearchResult({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchKeyword = ref.watch(searchKeywordProvider);
    final searchResults = ref.watch(searchResultsProvider);

    if (searchKeyword.isEmpty) {
      return const Center(child: Text('검색어를 입력하세요'));
    }

    return ListView(
      children: [
        StationSearchResult(
          stations: searchResults,
          searchKeyword: searchKeyword,
        ),
        // PlaceSearchResult(
        //     places: ['유성온천역 맥도날드', '유성문화원', '유성온천역', '스타벅스 유성온천역점']),
        // RouteSearchResult(routes: ["1호차", "2호차", "3호차", "4호차"]),
      ],
    );
  }
}
