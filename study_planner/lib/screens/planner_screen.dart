import 'package:flutter/material.dart';
import '../models/study_task.dart';
import '../services/task_service.dart';
import 'timer_screen.dart';

class PlannerScreen extends StatefulWidget {
  final DateTime selectedDate;

  const PlannerScreen({super.key, required this.selectedDate});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final TaskService _taskService = TaskService();
  List<StudyTask> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _loading = true);

    final data = await _taskService.fetchTasks(widget.selectedDate);

    setState(() {
      _tasks = data;
      _loading = false;
    });
  }

  String formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return "${h}시간 ${m}분 ${s}초";
  }

  Future<void> _addTaskDialog() async {
    final titleController = TextEditingController();
    final hourController = TextEditingController(text: "1");
    final minController = TextEditingController(text: "0");

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("할 일 추가"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "할 일"),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: hourController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "시간"),
                  ),
                ),
                const SizedBox(width: 10),
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
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isEmpty) return;

              final h = int.tryParse(hourController.text) ?? 0;
              final m = int.tryParse(minController.text) ?? 0;

              final goalSeconds = (h * 3600) + (m * 60);

              final task = StudyTask(
                id: '',
                date: widget.selectedDate,
                title: title,
                goalSeconds: goalSeconds,
                doneSeconds: 0,
              );

              await _taskService.insertTask(task);
              Navigator.pop(context);
              await _loadTasks();
            },
            child: const Text("추가"),
          ),
        ],
      ),
    );
  }

  Future<void> _startTimer(StudyTask task) async {
    final int? seconds = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => TimerScreen(taskTitle: task.title)),
    );

    if (seconds != null && seconds > 0) {
      await _taskService.updateDoneSeconds(task.id, task.doneSeconds + seconds);

      await _loadTasks();
    }
  }

  Future<void> _deleteTask(String id) async {
    await _taskService.deleteTask(id);
    await _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final dateText =
        "${widget.selectedDate.year}.${widget.selectedDate.month}.${widget.selectedDate.day}";

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                  icon: const Icon(Icons.add),
                  onPressed: _addTaskDialog,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _tasks.isEmpty
                  ? const Center(child: Text("할 일이 없습니다"))
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, i) {
                        final task = _tasks[i];

                        return Card(
                          child: ListTile(
                            title: Text(task.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("목표: ${formatTime(task.goalSeconds)}"),
                                Text("진행: ${formatTime(task.doneSeconds)}"),
                                const SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: task.goalSeconds == 0
                                      ? 0
                                      : (task.doneSeconds / task.goalSeconds)
                                            .clamp(0.0, 1.0),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == "start") {
                                  _startTimer(task);
                                } else if (value == "delete") {
                                  _deleteTask(task.id);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: "start",
                                  child: Text("공부 시작"),
                                ),
                                PopupMenuItem(
                                  value: "delete",
                                  child: Text("삭제"),
                                ),
                              ],
                            ),
                            onTap: () => _startTimer(task),
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
