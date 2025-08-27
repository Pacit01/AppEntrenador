import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'manage_teams.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'training_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onProfileUpdated;

  const ProfileScreen({super.key, this.onProfileUpdated});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Álex Ray';
  String _userTeam = 'U12 Escorpiones';
  //Variables para guardar evaluaciones

  Map<String, List<Map<String, String>>> _teamsPlayers = {
    'Premini': [
      {'name': 'Juan', 'number': '5', 'coach': '1º Entrenador'},
      {'name': 'María', 'number': '8', 'coach': '1º Entrenador'},
    ],
  };
  Map<String, Map<String, Map<String, int>>> _evaluations = {};

  Map<String, String> _teamCoach = {
    'Premini': '1º Entrenador',
  };

  String _selectedTeam = 'Premini';
  String _selectedMonth = 'Agosto 2025';
  final List<String> _months = ['Agosto 2025', 'Julio 2025'];

  final Map<String, Map<String, List<Map<String, String>>>> _sessions = {
    'Premini': {
      'Agosto 2025': [
        {
          'name': 'Táctica Defensiva',
          'date': '10 de agosto',
          'duration': '1 h'
        },
      ],
      'Julio 2025': [
        {
          'name': 'Rebotes y salida rápida',
          'date': '21 de julio',
          'duration': '1 h'
        },
      ],
    },
  };

  Map<String, Map<String, int>> _teamStats = {
    'Premini': {
      'Diversion': 0,
      'Aprendizaje': 0,
      'Efectividad': 0,
    },
  };
  void _updateTeamStats() {
    final today = DateTime.now();
    final teamSessions = _evaluations[_selectedTeam] ?? {};

    int diversionSum = 0;
    int aprendizajeSum = 0;
    int efectividadSum = 0;
    int count = 0;

    teamSessions.forEach((dateStr, stats) {
      final parts = dateStr.split('-'); // dd-MM-yyyy
      final date = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
      if (date.isBefore(today) || date.isAtSameMomentAs(today)) {
        diversionSum += stats['Diversion'] ?? 0;
        aprendizajeSum += stats['Aprendizaje'] ?? 0;
        efectividadSum += stats['Efectividad'] ?? 0;
        count++;
      }
    });

    if (count > 0) {
      _teamStats[_selectedTeam] = {
        'Diversion': (diversionSum / count).round(),
        'Aprendizaje': (aprendizajeSum / count).round(),
        'Efectividad': (efectividadSum / count).round(),
      };
    } else {
      _teamStats[_selectedTeam] = {
        'Diversion': 0,
        'Aprendizaje': 0,
        'Efectividad': 0
      };
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTeamsPlayers();
    _loadEvaluations();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Álex Ray';
      _userTeam = prefs.getString('team') ?? 'U12 Escorpiones';
    });
  }

  Future<void> _saveEvaluations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('evaluations', jsonEncode(_evaluations));
  }

  Future<void> _loadEvaluations() async {
    final prefs = await SharedPreferences.getInstance();
    final evalString = prefs.getString('evaluations');
    if (evalString != null) {
      final decoded = jsonDecode(evalString) as Map<String, dynamic>;
      _evaluations = decoded.map((team, sessions) {
        return MapEntry(
            team,
            (sessions as Map<String, dynamic>).map((date, stats) {
              return MapEntry(date, Map<String, int>.from(stats as Map));
            }));
      });
    }
    _updateTeamStats(); // recalcular medias
  }

  Future<void> _loadTeamsPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final teamsString = prefs.getString('teamsPlayers');
    final coachesString = prefs.getString('teamCoach');

    if (teamsString != null) {
      final decoded = jsonDecode(teamsString) as Map<String, dynamic>;
      _teamsPlayers = decoded.map((k, v) {
        final list = (v as List<dynamic>)
            .map((e) => Map<String, String>.from(e as Map))
            .toList();
        return MapEntry(k, list);
      });
    }

    if (coachesString != null) {
      final decodedCoaches = jsonDecode(coachesString) as Map<String, dynamic>;
      _teamCoach = decodedCoaches.map((k, v) => MapEntry(k, v.toString()));
    }

    setState(() {});
  }

  Future<void> _saveTeamsPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('teamsPlayers', jsonEncode(_teamsPlayers));
    await prefs.setString('teamCoach', jsonEncode(_teamCoach));
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _userName);
    final teamController = TextEditingController(text: _userTeam);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: teamController,
              decoration: const InputDecoration(labelText: 'Equipo'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('userName', nameController.text);
              await prefs.setString('team', teamController.text);

              setState(() {
                _userName = nameController.text;
                _userTeam = teamController.text;
              });

              widget.onProfileUpdated?.call();
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _openManageTeams() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManageTeamsScreen(
          teamsPlayers: _teamsPlayers,
          teamCoach: _teamCoach,
          onTeamsUpdated: () {
            setState(() {});
            widget.onProfileUpdated?.call();
            _saveTeamsPlayers();
          },
        ),
      ),
    );
    setState(() {});
    widget.onProfileUpdated?.call();
    _saveTeamsPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage:
                    NetworkImage('https://i.pravatar.cc/150?img=3'),
              ),
              const SizedBox(height: 16),
              Text(
                _userName,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _userTeam,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _editProfile,
                icon: const Icon(Icons.edit),
                label: const Text("Editar Perfil"),
              ),
              const SizedBox(height: 24),

              // Mis Equipos
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Mis Equipos',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ..._teamsPlayers.entries.map(
                        (entry) => ExpansionTile(
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.key,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${entry.value.length} Jugadores',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              entry.value.isNotEmpty
                                  ? (entry.value.first['coach'] ??
                                      _teamCoach[entry.key] ??
                                      'Sin entrenador')
                                  : (_teamCoach[entry.key] ?? 'Sin entrenador'),
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ),
                          children: entry.value
                              .map(
                                (player) => ListTile(
                                  title: Text(player['name'] ?? ''),
                                  trailing: Text('#${player['number'] ?? ''}'),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _openManageTeams,
                        child: const Text('Gestionar mis equipos'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Historial de Entrenamientos
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Historial de Entrenamientos',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Revisa las sesiones de entrenamiento pasadas para el equipo seleccionado.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      DropdownButton<String>(
                        value: _selectedTeam,
                        items: _teamsPlayers.keys.map((team) {
                          return DropdownMenuItem<String>(
                            value: team,
                            child: Text(team),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedTeam = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButton<String>(
                        value: _selectedMonth,
                        items: ['Todos', ..._months].map((month) {
                          return DropdownMenuItem<String>(
                            value: month,
                            child: Text(month),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedMonth = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: (_selectedMonth == 'Todos'
                                    ? _sessions[_selectedTeam]
                                        ?.values
                                        .expand((s) => s)
                                        .toList()
                                    : _sessions[_selectedTeam]?[_selectedMonth])
                                ?.map((s) {
                              return ListTile(
                                title: Text(s['name'] ?? ''),
                                subtitle:
                                    Text('${s['date']} / ${s['duration']}'),
                                onTap: () async {
                                  final dateParts = s['date']?.split(' de ') ??
                                      ['1', 'enero'];
                                  final day = int.tryParse(dateParts[0]) ?? 1;
                                  final monthName = dateParts[1].toLowerCase();
                                  final monthMap = {
                                    'enero': 1,
                                    'febrero': 2,
                                    'marzo': 3,
                                    'abril': 4,
                                    'mayo': 5,
                                    'junio': 6,
                                    'julio': 7,
                                    'agosto': 8,
                                    'septiembre': 9,
                                    'octubre': 10,
                                    'noviembre': 11,
                                    'diciembre': 12
                                  };
                                  final month = monthMap[monthName] ?? 1;
                                  final date = DateTime(2025, month, day);
                                  final dateStr =
                                      '${date.day.toString().padLeft(2, '0')}-'
                                      '${date.month.toString().padLeft(2, '0')}-'
                                      '${date.year}';
                                  final existingEvaluation =
                                      _evaluations[_selectedTeam]?[dateStr] ??
                                          {};
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TrainingScreen(
                                        trainingSession: {
                                          'objective': s['name'] ?? '',
                                          'date': date,
                                          'duration': s['duration'] ?? '',
                                          'exercises': s['exercises'] ?? [],
                                          'description': s['description'] ?? '',
                                          'evaluation': existingEvaluation,
                                        },
                                        onEvaluationSaved: (evaluation) async {
                                          final dateStr =
                                              '${date.day.toString().padLeft(2, '0')}-'
                                              '${date.month.toString().padLeft(2, '0')}-'
                                              '${date.year}';

                                          // Inicializamos el mapa de evaluaciones del equipo si no existe
                                          _evaluations[_selectedTeam] ??= {};

                                          // Guardamos la evaluación de la sesión concreta
                                          _evaluations[_selectedTeam]![
                                              dateStr] = {
                                            'Diversion':
                                                evaluation['Diversion'] ?? 0,
                                            'Aprendizaje':
                                                evaluation['Aprendizaje'] ?? 0,
                                            'Efectividad':
                                                evaluation['Efectividad'] ?? 0,
                                          };

                                          await _saveEvaluations(); // Guardamos en SharedPreferences
                                          _updateTeamStats(); // Recalculamos medias
                                          setState(() {}); // Refrescamos la UI
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList() ??
                            [],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Estadísticas del equipo
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estadísticas del equipo',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Evaluación promedio mensual por categoría',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      DropdownButton<String>(
                        value: _selectedTeam,
                        items: _teamsPlayers.keys.map((team) {
                          return DropdownMenuItem<String>(
                            value: team,
                            child: Text(team),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedTeam = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 100,
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(
                                      toY: _teamStats[_selectedTeam]
                                                  ?['Diversion']
                                              ?.toDouble() ??
                                          0,
                                      color: Colors.blue,
                                      width: 15),
                                  BarChartRodData(
                                      toY: _teamStats[_selectedTeam]
                                                  ?['Aprendizaje']
                                              ?.toDouble() ??
                                          0,
                                      color: Colors.green,
                                      width: 15),
                                  BarChartRodData(
                                      toY: _teamStats[_selectedTeam]
                                                  ?['Efectividad']
                                              ?.toDouble() ??
                                          0,
                                      color: Colors.orange,
                                      width: 15),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          LegendItem(color: Colors.blue, text: 'Diversión'),
                          LegendItem(color: Colors.green, text: 'Aprendizaje'),
                          LegendItem(color: Colors.orange, text: 'Efectividad'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Botón de cerrar sesión al final
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (!mounted) return;
                Navigator.of(context).pushReplacementNamed('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}
