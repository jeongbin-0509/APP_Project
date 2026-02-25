import 'package:flutter/material.dart';

void main() {
  runApp(const StudyPlannerApp());
}

class StudyPlannerApp extends StatelessWidget {
  const StudyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PlannerScreen(),
    );
  }
}

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final TextEditingController mathCurrent = TextEditingController();
  final TextEditingController mathTarget = TextEditingController();
  final TextEditingController englishCurrent = TextEditingController();
  final TextEditingController englishTarget = TextEditingController();
  final TextEditingController dailyTime = TextEditingController();
  final TextEditingController minTimeController = TextEditingController();

  double mathTime = 0;
  double englishTime = 0;

  void calculate() {
    int mCurrent = int.tryParse(mathCurrent.text) ?? 0;
    int mTarget = int.tryParse(mathTarget.text) ?? 0;
    int eCurrent = int.tryParse(englishCurrent.text) ?? 0;
    int eTarget = int.tryParse(englishTarget.text) ?? 0;
    int totalTime = int.tryParse(dailyTime.text) ?? 0;
    double minTime = double.tryParse(minTimeController.text) ?? 0;

    int mathGap = (mTarget - mCurrent).clamp(0, 100);
    int englishGap = (eTarget - eCurrent).clamp(0, 100);

    int totalGap = mathGap + englishGap;

    double totalMinTime = minTime * 2;

    if (totalTime < totalMinTime) {
      // 최소시간이 하루시간보다 크면 그냥 균등분배
      setState(() {
        mathTime = totalTime / 2;
        englishTime = totalTime / 2;
      });
      return;
    }

    double remainingTime = totalTime - totalMinTime;

    setState(() {
      if (totalGap == 0) {
        // gap이 모두 0이면 최소시간만 유지
        mathTime = minTime;
        englishTime = minTime;
      } else {
        mathTime = minTime + (mathGap / totalGap) * remainingTime;
        englishTime = minTime + (englishGap / totalGap) * remainingTime;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Study Planner")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text("📊 성적 입력", style: TextStyle(fontSize: 18)),

              TextField(
                controller: mathCurrent,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "수학 현재 점수"),
              ),

              TextField(
                controller: mathTarget,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "수학 목표 점수"),
              ),

              TextField(
                controller: englishCurrent,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "영어 현재 점수"),
              ),

              TextField(
                controller: englishTarget,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "영어 목표 점수"),
              ),

              TextField(
                controller: dailyTime,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "하루 공부 가능 시간 (시간 단위)",
                ),
              ),

              TextField(
                controller: minTimeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "과목당 최소 공부시간"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: calculate,
                child: const Text("시간 배분 계산"),
              ),

              const SizedBox(height: 30),

              Text("📘 수학 추천 공부시간: ${mathTime.toStringAsFixed(1)} 시간"),
              Text("📗 영어 추천 공부시간: ${englishTime.toStringAsFixed(1)} 시간"),
            ],
          ),
        ),
      ),
    );
  }
}
