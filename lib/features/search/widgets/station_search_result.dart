import 'package:client/core/theme/theme.dart';
import 'package:client/data/models/station_model.dart';
import 'package:client/features/home/widgets/map/providers/naver_map_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StationSearchResult extends ConsumerWidget {
  final List<StationModel> stations;
  final String searchKeyword;

  const StationSearchResult(
      {super.key, required this.stations, required this.searchKeyword});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(
          Icons.directions_bus_rounded,
          '정류장',
          AppTheme.primarySwatch,
        ),
        stations.isNotEmpty ? _buildList(stations, ref) : _buildEmptyMessage(),
      ],
    );
  }

  Widget _buildHeader(IconData icon, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: color,
            ),
            child: Row(
              children: [
                Icon(icon, size: 24, color: AppTheme.mainWhite),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontVariations: [FontVariation('wght', 800)],
                    fontSize: 16,
                    color: AppTheme.mainWhite,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 정류장 리스트 UI
  Widget _buildList(List<StationModel> stations, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightGray),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: stations.length,
        itemBuilder: (context, index) {
          final station = stations[index];
          if (station.name == null) {
            return const SizedBox.shrink();
          }

          final bool isDeparture = station.isDeparture ?? false;
          final Color color = AppTheme.mainWhite;
          final Color textColor = isDeparture
              ? const Color.fromARGB(255, 123, 169, 245)
              : AppTheme.secondarySwatch;
          return ListTile(
            onTap: () {
              ref.read(naverMapViewModelProvider.notifier).onStationSelected(
                    station.id,
                    station.latitude!,
                    station.longitude!,
                    null,
                  );
              Navigator.of(context).pop();
            },
            title: Row(
              children: [
                _highlightSearchKeyword(
                  _removeNewlines(station.name ?? ""),
                  isTitle: true,
                ),
                if (station.isDeparture != null)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: color,
                      border: Border.all(
                        color: textColor,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 6,
                    ),
                    child: Text(
                      station.isDeparture! ? "승차" : "하차",
                      style: AppTheme.textTheme.labelSmall?.copyWith(
                        fontVariations: [FontVariation('wght', 800)],
                        color: textColor,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (station.description != null &&
                    station.description!.isNotEmpty)
                  _highlightSearchKeyword(
                    _removeNewlines(station.description!),
                  ),
                _highlightSearchKeyword(_removeNewlines(station.address ?? "")),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) =>
            Container(height: 1, color: AppTheme.lightGray),
      ),
    );
  }

  // 검색어가 포함된 부분만 굵게 처리
  Text _highlightSearchKeyword(String text, {bool isTitle = false}) {
    TextStyle textStyle =
        isTitle ? AppTheme.textTheme.bodyLarge! : AppTheme.textTheme.bodySmall!;

    if (searchKeyword.isEmpty) {
      return Text(text);
    }

    final int startIndex =
        text.toLowerCase().indexOf(searchKeyword.toLowerCase());
    if (startIndex == -1) {
      return Text(text, style: textStyle);
    }

    final List<TextSpan> spans = <TextSpan>[];

    // 키워드 이전
    spans.add(
      TextSpan(
        text: text.substring(
          0,
          startIndex,
        ),
        style: textStyle,
      ),
    );

    // 키워드 볼드 처리
    spans.add(TextSpan(
      text: text.substring(startIndex, startIndex + searchKeyword.length),
      style: textStyle.copyWith(
        fontVariations: [FontVariation('wght', 700)],
      ),
    ));

    // 키워드 이후
    spans.add(TextSpan(
      text: text.substring(startIndex + searchKeyword.length),
      style: textStyle,
    ));

    return Text.rich(
      TextSpan(children: spans, style: textStyle),
    );
  }

  // 문자열에서 줄바꿈 문자 제거
  String _removeNewlines(String text) {
    return text.replaceAll('\n', ' ');
  }

  Widget _buildEmptyMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightGray),
        borderRadius: BorderRadius.circular(
          4,
        ),
      ),
      child: const Center(
        child: Text(
          '검색 결과가 없습니다.',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.mainGray,
          ),
        ),
      ),
    );
  }
}
