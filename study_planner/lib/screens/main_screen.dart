import 'package:flutter/material.dart';
import 'package:study_planner/models/study_task.dart';
import 'package:study_planner/screens/home_screen.dart';
import 'package:study_planner/screens/planner_screen.dart';
import 'package:study_planner/screens/settings_screen.dart';
import 'package:study_planner/screens/stats_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// 날짜 Key 통일(시/분/초 제거)
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String uid() => DateTime.now().microsecondsSinceEpoch.toString();

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  DateTime selectedDate = dateOnly(DateTime.now());

  // 날짜별 할 일 목록
  final Map<DateTime, List<StudyTask>> tasksByDate = {};

  @override
  void initState() {
    super.initState();

    // 샘플 데이터(오늘)
    tasksByDate[selectedDate] = [
      StudyTask(id: uid(), title: "수학 - 미적분 문제 20문제", goalSeconds: 60 * 60),
      StudyTask(id: uid(), title: "영어 - 단어 50개", goalSeconds: 30 * 60),
      StudyTask(id: uid(), title: "과학 - 개념 정리", goalSeconds: 45 * 60),
    ];
  }

  List<StudyTask> getTasks(DateTime date) {
    final key = dateOnly(date);
    return tasksByDate[key] ?? [];
  }

  void setSelectedDate(DateTime date) {
    setState(() {
      selectedDate = dateOnly(date);
      tasksByDate[selectedDate] ??= [];
    });
  }

  // 할 일 추가
  void addTask(DateTime date, StudyTask task) {
    final key = dateOnly(date);
    setState(() {
      tasksByDate[key] ??= [];
      tasksByDate[key]!.add(task);
    });
  }

  // 할 일 삭제
  void removeTask(DateTime date, String taskId) {
    final key = dateOnly(date);
    setState(() {
      tasksByDate[key]?.removeWhere((t) => t.id == taskId);
    });
  }

  // 목표시간 수정
  void updateTask(DateTime date, StudyTask updated) {
    final key = dateOnly(date);
    setState(() {
      final list = tasksByDate[key] ?? [];
      final idx = list.indexWhere((t) => t.id == updated.id);
      if (idx != -1) {
        list[idx] = updated;
      }
      tasksByDate[key] = list;
    });
  }

  // 타이머 결과(초) 누적
  void addStudySecondsToTask(DateTime date, String taskId, int seconds) {
    if (seconds <= 0) return;
    final key = dateOnly(date);
    setState(() {
      final list = tasksByDate[key] ?? [];
      final idx = list.indexWhere((t) => t.id == taskId);
      if (idx == -1) return;

      final task = list[idx];
      task.doneSeconds += seconds;

      // 과하게 누적되면 목표 초과 허용은 가능하지만,
      // 완료 처리/UI를 위해 doneSeconds는 그대로 두고 progress에서 clamp 처리
      list[idx] = task;
      tasksByDate[key] = list;
    });
  }

  int get totalGoalSecondsToday {
    return getTasks(selectedDate).fold(0, (sum, t) => sum + t.goalSeconds);
  }

  int get totalDoneSecondsToday {
    return getTasks(selectedDate).fold(0, (sum, t) => sum + t.doneSeconds);
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        date: selectedDate,
        tasks: getTasks(selectedDate),
        totalGoalSeconds: totalGoalSecondsToday,
        totalDoneSeconds: totalDoneSecondsToday,
        onGoPlanner: () => _onItemTapped(1),
      ),
      PlannerScreen(
        selectedDate: selectedDate,
        tasks: getTasks(selectedDate),
        tasksByDate: tasksByDate,
        onSelectDate: setSelectedDate,
        onAddTask: addTask,
        onRemoveTask: removeTask,
        onUpdateTask: updateTask,
        onAddStudySecondsToTask: addStudySecondsToTask,
      ),
      StatsScreen(tasksByDate: tasksByDate),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("성적설계")),
      body: pages[_selectedIndex],
      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text("사용자"),
              accountEmail: Text("example@email.com"),
              currentAccountPicture: CircleAvatar(
                child: Icon(Icons.person, size: 40),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("설정"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("로그아웃"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_calendar),
            label: "플래너",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "통계"),
        ],
      ),
    );
  }
}
