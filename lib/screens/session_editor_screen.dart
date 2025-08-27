import 'package:flutter/material.dart';

class SessionEditorScreen extends StatefulWidget {
  final Map<String, dynamic> session;

  const SessionEditorScreen({super.key, required this.session});

  @override
  _SessionEditorScreenState createState() => _SessionEditorScreenState();
}

class _SessionEditorScreenState extends State<SessionEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late List<Map<String, dynamic>> _categories;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.session["title"]);
    _descriptionController =
        TextEditingController(text: widget.session["description"] ?? "");
    _categories =
        List<Map<String, dynamic>>.from(widget.session["categories"] ?? []);
  }

  void _addCategory() {
    setState(() {
      _categories.add({"title": "Nueva categoría", "exercises": []});
    });
  }

  void _addExercise(int categoryIndex) {
    setState(() {
      _categories[categoryIndex]["exercises"].add({
        "name": "Nuevo ejercicio",
        "type": "Calentamiento",
        "description": "",
      });
    });
  }

  void _saveAndExit() {
    final updatedSession = {
      "title": _titleController.text,
      "description": _descriptionController.text,
      "categories": _categories,
    };
    Navigator.pop(context, updatedSession);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar sesión"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Título de la sesión"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Descripción"),
            ),
          ),
          Expanded(
            child: ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _categories.removeAt(oldIndex);
                  _categories.insert(newIndex, item);
                });
              },
              children: [
                for (int i = 0; i < _categories.length; i++)
                  Card(
                    key: ValueKey("cat_$i"),
                    margin: const EdgeInsets.all(8),
                    child: ExpansionTile(
                      title: TextField(
                        controller: TextEditingController(
                          text: _categories[i]["title"],
                        ),
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Título categoría"),
                        onChanged: (value) {
                          _categories[i]["title"] = value;
                        },
                      ),
                      children: [
                        for (int j = 0;
                            j < _categories[i]["exercises"].length;
                            j++)
                          ListTile(
                            title: Column(
                              children: [
                                TextField(
                                  controller: TextEditingController(
                                    text: _categories[i]["exercises"][j]["name"],
                                  ),
                                  decoration: const InputDecoration(
                                      labelText: "Nombre del ejercicio"),
                                  onChanged: (value) {
                                    _categories[i]["exercises"][j]["name"] = value;
                                  },
                                ),
                                TextField(
                                  controller: TextEditingController(
                                    text: _categories[i]["exercises"][j]["type"],
                                  ),
                                  decoration: const InputDecoration(
                                      labelText: "Tipo de ejercicio"),
                                  onChanged: (value) {
                                    _categories[i]["exercises"][j]["type"] = value;
                                  },
                                ),
                                TextField(
                                  controller: TextEditingController(
                                    text: _categories[i]["exercises"][j]
                                        ["description"],
                                  ),
                                  decoration: const InputDecoration(
                                      labelText: "Descripción"),
                                  onChanged: (value) {
                                    _categories[i]["exercises"][j]["description"] =
                                        value;
                                  },
                                ),
                              ],
                            ),
                          ),
                        TextButton.icon(
                          onPressed: () => _addExercise(i),
                          icon: const Icon(Icons.add),
                          label: const Text("Añadir ejercicio"),
                        )
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _addCategory,
                  icon: const Icon(Icons.add),
                  label: const Text("Añadir categoría"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _saveAndExit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(55),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text("Guardar cambios"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
