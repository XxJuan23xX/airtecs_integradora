import 'package:flutter/material.dart';

class WidgetNavbar extends StatelessWidget {
  final String title;

  const WidgetNavbar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 80,
      color: Colors.blue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications, color: Colors.white),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.bar_chart, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
