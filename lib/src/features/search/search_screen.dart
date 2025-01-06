import 'package:client/src/common/widgets/map_search_bar/map_search_bar.dart';
import 'package:client/src/features/search/components/search_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.1,
        title: const MapSearchBar(),
        // backgroundColor: AppTheme.primarySwatch,
      ),
      body: const SizedBox(
        width: double.infinity,
        height: double.infinity,
        // padding: const EdgeInsets.all(16.0),
        child: SearchResult(),
      ),
    );
  }
}
