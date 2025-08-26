import 'exercise.dart';

class TrainingSession {
  final String id;
  final String date;
  final String teamId;
  final List<Exercise> exercises;

  TrainingSession({
    required this.id,
    required this.date,
    required this.teamId,
    required this.exercises,
  });
}
