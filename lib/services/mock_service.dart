import '../models/player.dart';
import '../models/team.dart';
import '../models/exercise.dart';
import '../models/training_session.dart';

class MockService {
  List<Team> teams = [
    Team(id: '1', name: 'U12 Escorpiones', category: 'Mini'),
    Team(id: '2', name: 'U14 Tigres', category: 'Infantil'),
  ];

  List<Player> players = [
    Player(id: '1', name: 'Juan', jersey: 10, teamId: '1'),
    Player(id: '2', name: 'Luis', jersey: 12, teamId: '1'),
    Player(id: '3', name: 'Ana', jersey: 7, teamId: '2'),
  ];

  List<Exercise> exercises = [
    Exercise(id: '1', title: 'Dribling básico', description: 'Ejercicio de dribling...'),
    Exercise(id: '2', title: 'Tiro a canasta', description: 'Ejercicio de tiro...'),
  ];

  List<TrainingSession> sessions = [
    TrainingSession(id: '1', date: '2025-08-26', teamId: '1', exercises: []),
    TrainingSession(id: '2', date: '2025-08-27', teamId: '2', exercises: []),
  ];
}
