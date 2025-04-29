import 'package:client/core/theme/theme.dart';
import 'package:client/features/search/providers/search_providers.dart';
import 'package:client/features/search/widgets/search_result.dart';
import 'package:client/shared/widgets/map_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          color: AppTheme.mainGray,
          onPressed: () {
            ref.read(searchKeywordProvider.notifier).state = '';
            ref.read(searchResultsProvider.notifier).state = [];

            context.pop();
          },
        ),
        toolbarHeight: MediaQuery.of(context).size.height * 0.1,
        title: const MapSearchBar(),
        // backgroundColor: AppTheme.primarySwatch,
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        // padding: const EdgeInsets.all(16.0),
        child: SearchResult(),
      ),
    );
  }
}
