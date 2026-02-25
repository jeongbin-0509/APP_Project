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

  double mathTime = 0;
  double englishTime = 0;

  void calculate() {
    int mCurrent = int.tryParse(mathCurrent.text) ?? 0;
    int mTarget = int.tryParse(mathTarget.text) ?? 0;
    int eCurrent = int.tryParse(englishCurrent.text) ?? 0;
    int eTarget = int.tryParse(englishTarget.text) ?? 0;
    int totalTime = int.tryParse(dailyTime.text) ?? 0;

    int mathGap = mTarget - mCurrent;
    int englishGap = eTarget - eCurrent;

    int totalGap = mathGap + englishGap;

    if (totalGap <= 0) return;

    setState(() {
      mathTime = (mathGap / totalGap) * totalTime;
      englishTime = (englishGap / totalGap) * totalTime;
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
