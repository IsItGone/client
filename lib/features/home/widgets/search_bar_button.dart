import 'package:client/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchBarButton extends StatelessWidget {
  const SearchBarButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/search'),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.subWhite,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          children: const [
            Icon(Icons.search, color: AppTheme.mainGray),
            SizedBox(width: 8),
            Text(
              '정류장 또는 장소 검색',
              style: TextStyle(
                color: AppTheme.mainGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
