import 'dart:developer';

import 'package:client/core/theme/theme.dart';
import 'package:client/core/utils/debouncer.dart';
import 'package:client/data/providers/station_providers.dart';
import 'package:client/features/search/providers/search_providers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MapSearchBar extends ConsumerStatefulWidget {
  const MapSearchBar({super.key});

  @override
  ConsumerState<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends ConsumerState<MapSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final Debouncer _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    _debouncer.run(() {
      final keyword = _controller.text.trim();
      log(keyword);
      if (keyword.isNotEmpty) {
        // 검색어 상태를 업데이트
        ref.read(searchKeywordProvider.notifier).state = keyword;

        _searchStations(keyword);
      }
    });
  }

  Future<void> _searchStations(String keyword) async {
    try {
      final result = await ref.read(
          StationProviders.searchStationByKeywordProvider(keyword).future);

      log('result : $result');
      ref.read(searchResultsProvider.notifier).state = result;
    } catch (e) {
      // 오류 처리 (검색 결과 없음 등)
      ref.read(searchResultsProvider.notifier).state = [];
    }
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String currentUrl = GoRouterState.of(context).path ?? "";

    return TextField(
      controller: _controller,
      autofocus: true,
      onTap: () {
        if (currentUrl == '/') {
          context.push(
            '/search',
          );
        } else {}
      },
      decoration: const InputDecoration(
        hintText: '정류장 또는 장소 검색',
        prefixIcon: Icon(Icons.search),
        prefixIconColor: AppTheme.mainGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: AppTheme.subWhite,
      ),
    );
  }
}
