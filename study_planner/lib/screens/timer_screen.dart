import 'dart:async';
import 'package:flutter/material.dart';

class TimerScreen extends StatefulWidget {
  final String taskTitle;

  const TimerScreen({super.key, required this.taskTitle});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final Stopwatch sw = Stopwatch();
  Timer? ticker;
  bool running = false;

  void start() {
    sw.start();
    ticker?.cancel();
    ticker = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
    setState(() => running = true);
  }

  void pause() {
    sw.stop();
    ticker?.cancel();
    setState(() => running = false);
  }

  void finish() {
    sw.stop();
    ticker?.cancel();
    Navigator.pop(context, sw.elapsed.inSeconds);
  }

  String format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = two(d.inHours);
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return "$h:$m:$s";
  }

  @override
  void dispose() {
    ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = sw.elapsed;

    return Scaffold(
      appBar: AppBar(title: const Text("순공 시간 측정")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              widget.taskTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                format(elapsed),
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!running)
                  ElevatedButton(onPressed: start, child: const Text("시작")),
                if (running)
                  ElevatedButton(onPressed: pause, child: const Text("일시정지")),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: finish,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("종료"),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Text(
              "종료하면 방금 측정한 순공 시간이 해당 할 일에 누적돼요.",
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
