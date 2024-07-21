import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ShuttleBusRoute(),
    );
  }
}

class ShuttleBusRoute extends StatefulWidget {
  const ShuttleBusRoute({super.key});

  @override
  _ShuttleBusRouteState createState() => _ShuttleBusRouteState();
}

class _ShuttleBusRouteState extends State<ShuttleBusRoute>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentStopIndex = 0;

  final List<String> stops = [
    '우송대학교 서캠퍼스 버스 정류장',
    '대전역 동광장 김희선 제육 짜글이식당 맞은편',
    '유천동 현대아파트 버스정류장',
    '도마네거리 (서부 교육지원청 앞)',
    '도안수목토아파트 버스 승강장',
    '유성온천역 5번 출구 맥도날드 앞',
    '삼성화재 유성 연수원',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _currentStopIndex = (_currentStopIndex + 1) % stops.length;
          });
          _controller.reset();
          _startBusAnimation();
        }
      });

    _startBusAnimation();
  }

  void _startBusAnimation() {
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3호차')),
      body: CustomPaint(
        painter: RoutePainter(
          stops: stops,
          currentStopIndex: _currentStopIndex,
          animationValue: _animation.value,
        ),
        child: Container(height: MediaQuery.of(context).size.height),
      ),
    );
  }
}

class RoutePainter extends CustomPainter {
  final List<String> stops;
  final int currentStopIndex;
  final double animationValue;

  RoutePainter({
    required this.stops,
    required this.currentStopIndex,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double heightStep = size.height / stops.length;
    Paint linePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2.0;

    Paint circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    Paint circleBorderPaint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    Paint busPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // Draw the line
    for (int i = 0; i < stops.length - 1; i++) {
      Offset start = Offset(50, heightStep * i + heightStep / 2);
      Offset end = Offset(50, heightStep * (i + 1) + heightStep / 2);
      canvas.drawLine(start, end, linePaint);
    }

    // Draw the stops
    for (int i = 0; i < stops.length; i++) {
      Offset circleCenter = Offset(50, heightStep * i + heightStep / 2);
      canvas.drawCircle(circleCenter, 10, circlePaint);
      canvas.drawCircle(circleCenter, 10, circleBorderPaint);
    }

    // Draw the bus
    if (currentStopIndex < stops.length - 1) {
      Offset start = Offset(50, heightStep * currentStopIndex + heightStep / 2);
      Offset end =
          Offset(50, heightStep * (currentStopIndex + 1) + heightStep / 2);
      Offset busPosition = Offset.lerp(start, end, animationValue)!;
      canvas.drawCircle(busPosition, 12, busPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
