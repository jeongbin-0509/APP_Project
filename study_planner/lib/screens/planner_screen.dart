import 'package:flutter/material.dart';
import 'package:study_planner/models/study_task.dart';
import 'package:study_planner/screens/timer_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class PlannerScreen extends StatefulWidget {
  final DateTime selectedDate;
  final List<StudyTask> tasks;

  // 모든 날짜 데이터(캘린더 마커용)
  final Map<DateTime, List<StudyTask>> tasksByDate;

  final void Function(DateTime date) onSelectDate;
  final void Function(DateTime date, StudyTask task) onAddTask;
  final void Function(DateTime date, String taskId) onRemoveTask;
  final void Function(DateTime date, StudyTask updated) onUpdateTask;
  final void Function(DateTime date, String taskId, int seconds)
  onAddStudySecondsToTask;

  const PlannerScreen({
    super.key,
    required this.selectedDate,
    required this.tasks,
    required this.tasksByDate,
    required this.onSelectDate,
    required this.onAddTask,
    required this.onRemoveTask,
    required this.onUpdateTask,
    required this.onAddStudySecondsToTask,
  });

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
String uid() => DateTime.now().microsecondsSinceEpoch.toString();

class _PlannerScreenState extends State<PlannerScreen> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDate;
  }

  String formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return "${h}시간 ${m}분 ${s}초";
  }

  List<StudyTask> _eventsForDay(DateTime day) {
    final key = dateOnly(day);
    return widget.tasksByDate[key] ?? [];
  }

  Future<void> _showAddTaskDialog(DateTime date) async {
    final titleController = TextEditingController();
    final hourController = TextEditingController(text: "1");
    final minController = TextEditingController(text: "0");

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("오늘의 할 일 추가"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "할 일 (예: 수학 문제 20문제)",
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: hourController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "시간"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: minController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "분"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "※ 목표시간은 '순공 목표'로 저장돼요.",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) return;

                final h = int.tryParse(hourController.text) ?? 0;
                final m = int.tryParse(minController.text) ?? 0;
                final goalSeconds = (h * 3600) + (m * 60);

                widget.onAddTask(
                  date,
                  StudyTask(
                    id: uid(),
                    title: title,
                    goalSeconds: goalSeconds <= 0
                        ? 30 * 60
                        : goalSeconds, // 최소 30분 기본
                  ),
                );

                Navigator.pop(context);
              },
              child: const Text("추가"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditTaskDialog(DateTime date, StudyTask task) async {
    final titleController = TextEditingController(text: task.title);

    final initHours = task.goalSeconds ~/ 3600;
    final initMinutes = (task.goalSeconds % 3600) ~/ 60;

    final hourController = TextEditingController(text: initHours.toString());
    final minController = TextEditingController(text: initMinutes.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("할 일 수정"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "할 일"),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: hourController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "시간"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: minController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "분"),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) return;

                final h = int.tryParse(hourController.text) ?? 0;
                final m = int.tryParse(minController.text) ?? 0;
                final goalSeconds = (h * 3600) + (m * 60);

                final updated = StudyTask(
                  id: task.id,
                  title: title,
                  goalSeconds: goalSeconds <= 0
                      ? task.goalSeconds
                      : goalSeconds,
                  doneSeconds: task.doneSeconds,
                );

                widget.onUpdateTask(date, updated);
                Navigator.pop(context);
              },
              child: const Text("저장"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startTimerForTask(DateTime date, StudyTask task) async {
    final int? seconds = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => TimerScreen(taskTitle: task.title)),
    );

    if (seconds != null && seconds > 0) {
      widget.onAddStudySecondsToTask(date, task.id, seconds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selectedDate;
    final dateText = "${selected.year}.${selected.month}.${selected.day}";

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 캘린더
            TableCalendar<StudyTask>(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(selected, day),
              eventLoader: _eventsForDay,
              onDaySelected: (sel, focused) {
                _focusedDay = focused;
                widget.onSelectDate(sel);
                setState(() {});
              },
              onPageChanged: (focused) {
                _focusedDay = focused;
              },
              calendarStyle: const CalendarStyle(
                markerDecoration: BoxDecoration(shape: BoxShape.circle),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Text(
                  "$dateText 할 일",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showAddTaskDialog(selected),
                  icon: const Icon(Icons.add),
                  tooltip: "할 일 추가",
                ),
              ],
            ),

            const SizedBox(height: 6),

            Expanded(
              child: widget.tasks.isEmpty
                  ? const Center(child: Text("이 날짜에 할 일이 없어요. + 버튼으로 추가해봐!"))
                  : ListView.builder(
                      itemCount: widget.tasks.length,
                      itemBuilder: (context, i) {
                        final t = widget.tasks[i];

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(
                                t.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  decoration: t.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Text("목표: ${formatTime(t.goalSeconds)}"),
                                  Text("진행: ${formatTime(t.doneSeconds)}"),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: t.progress,
                                    minHeight: 7,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == "start") {
                                    _startTimerForTask(selected, t);
                                  } else if (value == "edit") {
                                    _showEditTaskDialog(selected, t);
                                  } else if (value == "delete") {
                                    widget.onRemoveTask(selected, t.id);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: "start",
                                    child: Text("공부 시작(타이머)"),
                                  ),
                                  const PopupMenuItem(
                                    value: "edit",
                                    child: Text("수정"),
                                  ),
                                  const PopupMenuItem(
                                    value: "delete",
                                    child: Text("삭제"),
                                  ),
                                ],
                              ),
                              onTap: () => _startTimerForTask(selected, t),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
