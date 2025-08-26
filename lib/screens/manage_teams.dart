import 'package:flutter/material.dart';
import 'dart:convert'; // para jsonEncode y jsonDecode
import 'package:shared_preferences/shared_preferences.dart'; // para guardar datos locales

class ManageTeamsScreen extends StatefulWidget {
  final Map<String, List<Map<String, String>>> teamsPlayers;
  final Map<String, String> teamCoach; // entrenador por equipo
  final VoidCallback? onTeamsUpdated;

  const ManageTeamsScreen({
    super.key,
    required this.teamsPlayers,
    required this.teamCoach,
    this.onTeamsUpdated,
  });

  @override
  State<ManageTeamsScreen> createState() => _ManageTeamsScreenState();
}

class _ManageTeamsScreenState extends State<ManageTeamsScreen> {
  late Map<String, List<Map<String, String>>> _teamsPlayers;
  late Map<String, String> _teamCoach;

  @override
  void initState() {
    super.initState();
    // Referencias (mismo mapa) para modificar en sitio
    _teamsPlayers = widget.teamsPlayers;
    _teamCoach = widget.teamCoach;
  }

  void _notifyUpdated() {
    widget.onTeamsUpdated?.call();
  }

  Future<void> _addTeam() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Crear nuevo equipo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nombre del equipo'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty && !_teamsPlayers.containsKey(name)) {
                setState(() {
                  _teamsPlayers[name] = [];
                  _teamCoach[name] = '1º Entrenador'; // por defecto
                });
                _notifyUpdated();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
  Future<void> _saveTeamsData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('teamsPlayers', jsonEncode(_teamsPlayers));
    await prefs.setString('teamCoach', jsonEncode(_teamCoach));

    // 🔥 Notifica al ProfileScreen para que se actualice
    widget.onTeamsUpdated?.call();
  } 
  Future<void> _renameTeam(String oldName) async {
    final controller = TextEditingController(text: oldName);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renombrar equipo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nuevo nombre'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != oldName && !_teamsPlayers.containsKey(newName)) {
                setState(() {
                  _teamsPlayers[newName] = _teamsPlayers.remove(oldName)!;
                  // mover coach
                  final coach = _teamCoach.remove(oldName);
                  if (coach != null) _teamCoach[newName] = coach;
                });
                _notifyUpdated();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTeam(String team) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar equipo'),
        content: Text('¿Seguro que quieres eliminar "$team"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        _teamsPlayers.remove(team);
        _teamCoach.remove(team);
      });
      _notifyUpdated();
    }
  }

  Future<void> _chooseCoach(String team) async {
    String current = _teamCoach[team] ?? '1º Entrenador';
    String temp = current;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text('Entrenador de $team'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                value: '1º Entrenador',
                groupValue: temp,
                onChanged: (v) => setStateDialog(() => temp = v ?? '1º Entrenador'),
                title: const Text('1º Entrenador'),
              ),
              RadioListTile<String>(
                value: '2º Entrenador',
                groupValue: temp,
                onChanged: (v) => setStateDialog(() => temp = v ?? '2º Entrenador'),
                title: const Text('2º Entrenador'),
              ),
              RadioListTile<String>(
                value: '3º Entrenador',
                groupValue: temp,
                onChanged: (v) => setStateDialog(() => temp = v ?? '3º Entrenador'),
                title: const Text('3º Entrenador'),
              ),
              RadioListTile<String>(
                value: 'Preparador físico',
                groupValue: temp,
                onChanged: (v) => setStateDialog(() => temp = v ?? 'Preparador físico'),
                title: const Text('Preparador físico'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _teamCoach[team] = temp;
                  // Sincroniza con jugadores existentes
                  for (final p in _teamsPlayers[team]!) {
                    p['coach'] = temp;
                  }
                });
                _notifyUpdated();
                Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPlayer(String team) async {
    final nameCtrl = TextEditingController();
    final numCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Añadir jugador a $team'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Nombre'), controller: nameCtrl),
            TextField(
              decoration: const InputDecoration(labelText: 'Dorsal'),
              controller: numCtrl,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final number = numCtrl.text.trim();
              if (name.isNotEmpty && number.isNotEmpty) {
                setState(() {
                  _teamsPlayers[team]!.add({
                    'name': name,
                    'number': number,
                    'coach': _teamCoach[team] ?? '1º Entrenador',
                  });
                });
                _notifyUpdated();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  Future<void> _editPlayer(String team, int index) async {
    final nameCtrl = TextEditingController(text: _teamsPlayers[team]![index]['name']);
    final numCtrl = TextEditingController(text: _teamsPlayers[team]![index]['number']);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar jugador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Nombre'), controller: nameCtrl),
            TextField(
              decoration: const InputDecoration(labelText: 'Dorsal'),
              controller: numCtrl,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _teamsPlayers[team]![index]['name'] = nameCtrl.text.trim();
                _teamsPlayers[team]![index]['number'] = numCtrl.text.trim();
              });
              _notifyUpdated();
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePlayer(String team, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar jugador'),
        content: Text('¿Eliminar a "${_teamsPlayers[team]![index]['name']}" del equipo $team?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        _teamsPlayers[team]!.removeAt(index);
      });
      _notifyUpdated();
    }
  }

  Widget _teamHeader(String team) {
    return Row(
      children: [
        Expanded(
          child: Text(
            team,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Text('${_teamsPlayers[team]!.length} jugadores'),
      ],
    );
  }

  PopupMenuButton<String> _teamMenu(String team) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'rename':
            _renameTeam(team);
            break;
          case 'coach':
            _chooseCoach(team);
            break;
          case 'delete':
            _deleteTeam(team);
            break;
        }
      },
      itemBuilder: (ctx) => [
        const PopupMenuItem(value: 'rename', child: Text('Renombrar equipo')),
        const PopupMenuItem(value: 'coach', child: Text('Cambiar entrenador')),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Eliminar equipo'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _teamsPlayers.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar mis equipos'),
        actions: [
          IconButton(onPressed: _addTeam, icon: const Icon(Icons.add), tooltip: 'Añadir equipo'),
        ],
      ),
      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (ctx, i) {
          final entry = entries[i];
          final team = entry.key;
          final players = entry.value;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ExpansionTile(
              title: _teamHeader(team),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: GestureDetector(
                  onTap: () => _chooseCoach(team),
                  child: Text(
                    _teamCoach[team] ?? (players.isNotEmpty ? (players.first['coach'] ?? 'Sin entrenador') : 'Sin entrenador'),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
              trailing: _teamMenu(team),
              children: [
                ...players.asMap().entries.map((e) {
                  final idx = e.key;
                  final p = e.value;
                  return ListTile(
                    title: Text(p['name'] ?? ''),
                    subtitle: Text('Dorsal: ${p['number'] ?? ''}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit), onPressed: () => _editPlayer(team, idx)),
                        IconButton(icon: const Icon(Icons.delete), onPressed: () => _deletePlayer(team, idx)),
                      ],
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _addPlayer(team),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Añadir jugador'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
