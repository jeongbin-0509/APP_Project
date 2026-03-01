import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final DateTime selectedDate;

  const HomeScreen({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "홈 화면\n${selectedDate.year}.${selectedDate.month}.${selectedDate.day}",
        textAlign: TextAlign.center,
      ),
    );
  }
}
