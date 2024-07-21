import 'package:flutter/material.dart';

class TimelineScreen extends StatelessWidget {
  final List<Map<String, dynamic>> orderStatus = [
    {
      'status': 'Order Placed',
      'description': 'We have received your order.',
      'icon': Icons.receipt,
      'isCompleted': true,
    },
    {
      'status': 'Order Confirmed',
      'description': 'Your order has been confirmed.',
      'icon': Icons.thumb_up,
      'isCompleted': true,
    },
    {
      'status': 'Order Processed',
      'description': 'We are preparing your order.',
      'icon': Icons.local_shipping,
      'isCompleted': false,
    },
    {
      'status': 'Ready to Pickup',
      'description': 'Your order is ready for pickup.',
      'icon': Icons.shopping_bag,
      'isCompleted': false,
    },
  ];

  TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: orderStatus.length,
          itemBuilder: (context, index) {
            return TimelineTile(
              status: orderStatus[index]['status'],
              description: orderStatus[index]['description'],
              icon: orderStatus[index]['icon'],
              isCompleted: orderStatus[index]['isCompleted'],
              isFirst: index == 0,
              isLast: index == orderStatus.length - 1,
            );
          },
        ),
      ),
    );
  }
}

class TimelineTile extends StatelessWidget {
  final String status;
  final String description;
  final IconData icon;
  final bool isCompleted;
  final bool isFirst;
  final bool isLast;

  const TimelineTile({
    super.key,
    required this.status,
    required this.description,
    required this.icon,
    required this.isCompleted,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 4,
                height: 20,
                color: isCompleted ? Colors.green : Colors.grey,
              ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green : Colors.white,
                border: Border.all(
                  color: isCompleted ? Colors.green : Colors.grey,
                  width: 4,
                ),
              ),
              child: Icon(
                icon,
                color: isCompleted ? Colors.white : Colors.grey,
              ),
            ),
            if (!isLast)
              Container(
                width: 4,
                height: 20,
                color: isCompleted ? Colors.green : Colors.grey,
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.black : Colors.grey,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style:
                    TextStyle(color: isCompleted ? Colors.black : Colors.grey),
              ),
              const Column(
                children: [
                  Divider(
                    height: 1,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
