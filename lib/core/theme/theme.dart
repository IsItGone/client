import 'package:flutter/material.dart';

class AppTheme {
  static const int _primaryValue = 0xff574B90;
  static const int _secondaryValue = 0xff3954A5;

  static const Color mainBlack = Color(0xff141923);
  static const Color subBlack = Color(0xff303A52);
  static const Color mainGray = Color(0xff6C6C6C);
  static const Color lightGray = Color(0xffEEEEEE);
  static const Color mainRed = Color(0xffEF4A4A);
  static const Color mainWhite = Color(0xffffffff);
  static const Color subWhite = Color(0xfffefefe);

  static const List<Color> lineColors = [
    Color(_primaryValue),
    Color(0xff3498DB),
    Color(0xffFF8A98),
    Color(0xffF8C957),
    Color(0xff72B37E),
    Color(0xff437975),
    Color(0xffFFA96A),
  ];

  static const MaterialColor primarySwatch =
      MaterialColor(_primaryValue, <int, Color>{
    50: Color(0xfff2f3fb),
    100: Color(0xffe7e9f8),
    200: Color(0xffd3d5f2),
    300: Color(0xffb7baea),
    400: Color(0xff9c9adf),
    500: Color(0xff8881d3),
    600: Color(0xff7768c3),
    700: Color(0xff6657ab),
    800: Color(_primaryValue),
    900: Color(0xff46406f),
    950: Color(0xff2a2541),
  });

  static const MaterialColor secondarySwatch =
      MaterialColor(_secondaryValue, <int, Color>{
    50: Color(0xfff1f6fd),
    100: Color(0xffe0ebf9),
    200: Color(0xffc9ddf4),
    300: Color(0xffa4c7ec),
    400: Color(0xff78a9e2),
    500: Color(0xff588bd9),
    600: Color(0xff4471cc),
    700: Color(0xff3a5ebb),
    800: Color(0xff3954a5),
    900: Color(0xff2f4379),
    950: Color(0xff212b4a),
  });

// Define the text theme
  static const TextTheme textTheme = TextTheme(
    // displayLarge: TextStyle(
    //   fontSize: 32.0,
    //   fontWeight: FontWeight.w900,
    //   color: mainBlack,
    // ),
    // displayMedium: TextStyle(
    //   fontSize: 28.0,
    //   fontWeight: FontWeight.w800,
    //   color: mainBlack,
    // ),
    displaySmall: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.w800, // bottom drawer 노선 정보, 주변 정류장 목록 헤더
      color: subBlack,
    ),
    // headlineMedium: TextStyle(
    //   fontSize: 20.0,
    //   fontWeight: FontWeight.w700,
    //   color: mainBlack,
    // ),
    // headlineSmall: TextStyle(
    //   fontSize: 18.0,
    //   fontWeight: FontWeight.w600,
    //   color: mainBlack,
    // ),
    titleLarge: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w600, // 승차 운행 시간, 선형노선도 정류장 이름
      color: subBlack,
    ),
    // titleMedium: TextStyle(
    //   fontSize: 16.0,
    //   color: mainGray,
    // ),
    titleSmall: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w500, // 노선 종점 <->
      color: mainGray,
    ),
    bodyLarge: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w400, // 주변 정류장 이름, 검색 결과 정류장 이름
      color: mainBlack,
    ),
    bodyMedium: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w400, // 정류장 설명
      color: mainBlack,
    ),
    bodySmall: TextStyle(
      fontSize: 12.0,
      fontWeight: FontWeight.w400, // 정류장 주소, 검색 결과 정류장 주소
      color: mainGray,
    ),
    labelLarge: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w400, // 주변 정류장 거리
      color: primarySwatch,
    ),
    labelSmall: TextStyle(
      fontSize: 12.0,
      color: mainWhite,
    ),
  );
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primarySwatch[800]!,
    ),
    fontFamily: 'Pretendard',
    // fontFamilyFallback: ['sans-serif'],
    textTheme: textTheme,
  );
}
