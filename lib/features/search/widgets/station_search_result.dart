import 'package:client/core/theme/theme.dart';
import 'package:client/data/models/station_model.dart';
import 'package:flutter/material.dart';

class StationSearchResult extends StatelessWidget {
  final List<StationModel> stations;
  final String searchKeyword;

  const StationSearchResult(
      {super.key, required this.stations, required this.searchKeyword});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(
            Icons.directions_bus_rounded, '정류장', AppTheme.primarySwatch),
        stations.isNotEmpty ? _buildList(stations) : _buildEmptyMessage(),
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
                    fontWeight: FontWeight.bold,
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

  /// 📌 정류장 리스트 UI
  Widget _buildList(List<StationModel> stations) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightGray),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(0),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: stations.length,
        itemBuilder: (context, index) {
          final station = stations[index];
          return ListTile(
            title: _highlightSearchKeyword(_removeNewlines(station.name ?? "")),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _highlightSearchKeyword(
                    _removeNewlines(station.description ?? "")),
                _highlightSearchKeyword(_removeNewlines(station.address ?? "")),
              ],
            ),
            // trailing: Text(
            //   station.address ?? "",
            //   style: const TextStyle(
            //       color: Colors.green, fontWeight: FontWeight.bold),
            // ),
          );
        },
        separatorBuilder: (context, index) =>
            Container(height: 1, color: AppTheme.lightGray),
      ),
    );
  }

  /// 📌 검색어가 포함된 부분만 굵게 처리하는 메소드
  Text _highlightSearchKeyword(String text) {
    if (searchKeyword.isEmpty) {
      return Text(text);
    }

    final int startIndex =
        text.toLowerCase().indexOf(searchKeyword.toLowerCase());
    if (startIndex == -1) {
      return Text(text);
    }

    final List<TextSpan> spans = <TextSpan>[];

    // Add text before the search keyword
    spans.add(TextSpan(text: text.substring(0, startIndex)));

    // Add the search keyword part with bold style
    spans.add(TextSpan(
      text: text.substring(startIndex, startIndex + searchKeyword.length),
      style: const TextStyle(fontWeight: FontWeight.bold),
    ));

    // Add text after the search keyword
    spans
        .add(TextSpan(text: text.substring(startIndex + searchKeyword.length)));

    return Text.rich(
      TextSpan(children: spans),
    );
  }

  /// 📌 문자열에서 줄바꿈 문자 (\n) 제거
  String _removeNewlines(String text) {
    return text.replaceAll('\n', ' '); // \n 제거
  }

  Widget _buildEmptyMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.lightGray),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text(
          '검색 결과가 없습니다.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
