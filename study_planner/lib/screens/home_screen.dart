import 'package:flutter/material.dart';
import 'package:study_planner/models/study_task.dart';

class HomeScreen extends StatelessWidget {
  final DateTime date;
  final List<StudyTask> tasks;
  final int totalGoalSeconds;
  final int totalDoneSeconds;
  final VoidCallback onGoPlanner;

  const HomeScreen({
    super.key,
    required this.date,
    required this.tasks,
    required this.totalGoalSeconds,
    required this.totalDoneSeconds,
    required this.onGoPlanner,
  });

  String formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return "${h}시간 ${m}분 ${s}초";
  }

  @override
  Widget build(BuildContext context) {
    final progress = totalGoalSeconds == 0
        ? 0.0
        : (totalDoneSeconds / totalGoalSeconds).clamp(0.0, 1.0);

    final dateText = "${date.year}.${date.month}.${date.day}";

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$dateText · 오늘 플래너",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              "안정빈님, 오늘도 성장 중 🔥",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "오늘의 순공 요약",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("총 목표: ${formatTime(totalGoalSeconds)}"),
                    Text("현재 순공: ${formatTime(totalDoneSeconds)}"),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "달성률 ${(progress * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),
            const Text(
              "오늘의 할 일",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text("오늘 할 일이 비어있어요. 플래너에서 추가해보자!"))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, i) {
                        final t = tasks[i];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(t.title),
                            subtitle: Text(
                              "목표 ${formatTime(t.goalSeconds)} · 진행 ${formatTime(t.doneSeconds)}",
                            ),
                            trailing: Icon(
                              t.isCompleted
                                  ? Icons.check_circle
                                  : Icons.timelapse,
                            ),
                          ),
                        );
                      },
                    ),
            ),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onGoPlanner,
                child: const Text("플래너로 가서 공부 시작"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
