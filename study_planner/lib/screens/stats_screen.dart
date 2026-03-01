import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  final DateTime selectedDate;

  const StatsScreen({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "통계 화면\n${selectedDate.year}.${selectedDate.month}.${selectedDate.day}",
        textAlign: TextAlign.center,
      ),
    );
  }
}
