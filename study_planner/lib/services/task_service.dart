import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/study_task.dart';

class TaskService {
  final supabase = Supabase.instance.client;

  Future<List<StudyTask>> fetchTasks(DateTime date) async {
    final response = await supabase
        .from('tasks')
        .select()
        .eq('date', date.toIso8601String().split("T").first);

    final List data = response as List;

    return data.map((e) => StudyTask.fromMap(e)).toList();
  }

  Future<void> insertTask(StudyTask task) async {
    await supabase.from('tasks').insert(task.toMap());
  }

  Future<void> updateDoneSeconds(String id, int newSeconds) async {
    await supabase
        .from('tasks')
        .update({'done_seconds': newSeconds})
        .eq('id', id);
  }

  Future<void> deleteTask(String id) async {
    await supabase.from('tasks').delete().eq('id', id);
  }
}
