import 'package:flutter/material.dart';
import 'package:study_planner/models/study_task.dart';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class StatsScreen extends StatelessWidget {
  final Map<DateTime, List<StudyTask>> tasksByDate;

  const StatsScreen({super.key, required this.tasksByDate});

  String formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return "${h}시간 ${m}분 ${s}초";
  }

  @override
  Widget build(BuildContext context) {
    final dates = tasksByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // 최신 날짜 먼저

    if (dates.isEmpty) {
      return const SafeArea(child: Center(child: Text("아직 기록이 없어요.")));
    }

    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dates.length,
        itemBuilder: (context, i) {
          final d = dateOnly(dates[i]);
          final list = tasksByDate[d] ?? [];

          final goal = list.fold<int>(0, (sum, t) => sum + t.goalSeconds);
          final done = list.fold<int>(0, (sum, t) => sum + t.doneSeconds);

          final progress = goal == 0 ? 0.0 : (done / goal).clamp(0.0, 1.0);
          final title = "${d.year}.${d.month}.${d.day}";

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("목표: ${formatTime(goal)}"),
                  Text("순공: ${formatTime(done)}"),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 6),
                  Text("달성률 ${(progress * 100).toStringAsFixed(0)}%"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
