import 'dart:developer';

import 'package:client/src/config/theme.dart';

import 'package:flutter/material.dart';

class MapSearchBar extends StatelessWidget {
  const MapSearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: () => log('search bar tapped'),
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
