import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'manage_teams.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onProfileUpdated;

  const ProfileScreen({super.key, this.onProfileUpdated});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Álex Ray';
  String _userTeam = 'U12 Escorpiones';

  Map<String, List<Map<String, String>>> _teamsPlayers = {
    'Premini': [
      {'name': 'Juan', 'number': '5', 'coach': '1º Entrenador'},
      {'name': 'María', 'number': '8', 'coach': '1º Entrenador'},
    ],
  };

  Map<String, String> _teamCoach = {
    'Premini': '1º Entrenador',
  };

  String _selectedTeam = 'Premini';
  String _selectedMonth = 'Agosto 2025';
  final List<String> _months = ['Agosto 2025', 'Julio 2025'];

  final Map<String, Map<String, List<Map<String, String>>>> _sessions = {
    'Premini': {
      'Agosto 2025': [
        {'name': 'Táctica Defensiva', 'date': '10 de agosto', 'duration': '1 h'},
      ],
      'Julio 2025': [
        {'name': 'Rebotes y salida rápida', 'date': '21 de julio', 'duration': '1 h'},
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

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTeamsPlayers();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Álex Ray';
      _userTeam = prefs.getString('team') ?? 'U12 Escorpiones';
    });
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
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
              ),
              const SizedBox(height: 16),
              Text(
                _userName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                                      fontSize: 16, fontWeight: FontWeight.bold),
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                                ? _sessions[_selectedTeam]?.values.expand((s) => s).toList()
                                : _sessions[_selectedTeam]?[_selectedMonth])
                            ?.map((s) {
                          return ListTile(
                            title: Text(s['name'] ?? ''),
                            subtitle: Text('${s['date']} / ${s['duration']}'),
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                                      toY: _teamStats[_selectedTeam]?['Diversion']?.toDouble() ?? 0,
                                      color: Colors.blue,
                                      width: 15),
                                  BarChartRodData(
                                      toY: _teamStats[_selectedTeam]?['Aprendizaje']?.toDouble() ?? 0,
                                      color: Colors.green,
                                      width: 15),
                                  BarChartRodData(
                                      toY: _teamStats[_selectedTeam]?['Efectividad']?.toDouble() ?? 0,
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
