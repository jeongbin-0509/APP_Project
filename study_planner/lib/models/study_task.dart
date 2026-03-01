class StudyTask {
  final String id;
  String title;
  int goalSeconds;
  int doneSeconds;

  StudyTask({
    required this.id,
    required this.title,
    required this.goalSeconds,
    this.doneSeconds = 0,
  });

  bool get isCompleted => doneSeconds >= goalSeconds && goalSeconds > 0;

  double get progress {
    if (goalSeconds <= 0) return 0.0;
    return (doneSeconds / goalSeconds).clamp(0.0, 1.0);
  }
}
