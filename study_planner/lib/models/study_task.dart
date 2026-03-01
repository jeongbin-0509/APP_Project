class StudyTask {
  final String id;
  final DateTime date;
  final String title;
  final int goalSeconds;
  final int doneSeconds;

  StudyTask({
    required this.id,
    required this.date,
    required this.title,
    required this.goalSeconds,
    required this.doneSeconds,
  });

  factory StudyTask.fromMap(Map<String, dynamic> map) {
    return StudyTask(
      id: map['id'],
      date: DateTime.parse(map['date']),
      title: map['title'],
      goalSeconds: map['goal_seconds'],
      doneSeconds: map['done_seconds'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String().split("T").first,
      'title': title,
      'goal_seconds': goalSeconds,
      'done_seconds': doneSeconds,
    };
  }

  bool get inCompleted => doneSeconds >= goalSeconds;
}
