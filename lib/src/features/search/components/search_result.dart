import 'package:client/src/config/theme.dart';
import 'package:flutter/material.dart';

const List<String> busStop = ['유성온천역 맥도날드 앞', '유성문화원'];
const List<String> places = ['유성온천역 맥도날드', '유성문화원', '유성온천역', '스타벅스 유성온천역점'];
// const List<String> lines = ["1호차", "2호차", "3호차", "4호차"];

const List<Map<String, dynamic>> searchList = [
  {
    'title': '정류장',
    'icon': Icons.directions_bus_rounded,
    'color': AppTheme.primarySwatch,
    'items': busStop,
  },
  {
    'title': '장소',
    'icon': Icons.place,
    'color': Colors.blue,
    'items': places,
  },
  // {
  //   'title': '노선',
  //   'icon': Icons.linear_scale_sharp,
  //   'color': AppTheme.primarySwatch,
  //   'items': lines,
  // }
];

class SearchResult extends StatelessWidget {
  const SearchResult({super.key});

  Widget buildList(Map<String, dynamic> searchData) {
    final String title = searchData['title'];
    final IconData icon = searchData['icon'];
    final Color color = searchData['color'];
    final List<String> items = searchData['items'];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: color,
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 24,
                      color: AppTheme.mainWhite,
                    ),
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
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.lightGray),
            borderRadius: BorderRadius.circular(4),
            // color: Colors.amber,
          ),
          child: ListView.separated(
            padding: const EdgeInsets.all(0),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(items[index]),
              );
            },
            separatorBuilder: (context, index) => Container(
              height: 1,
              color: AppTheme.lightGray,
              margin: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: searchList.map((searchData) {
          return Column(
            children: [
              if (searchData['items'].isNotEmpty) ...[
                buildList(searchData),
                const SizedBox(height: 15),
              ]
            ],
          );
        }).toList(),
      ),
    );
  }
}
