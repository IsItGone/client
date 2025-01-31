import 'package:client/src/config/theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MapSearchBar extends ConsumerWidget {
  const MapSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String currentUrl = GoRouterState.of(context).path ?? "";

    return TextField(
      autofocus: true,
      onTap: () {
        if (currentUrl == '/') {
          context.push(
            '/search',
          );
        }
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
