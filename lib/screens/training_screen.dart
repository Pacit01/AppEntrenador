import 'package:flutter/material.dart';
import 'session_editor_screen.dart'; // Importa la pantalla de edición

class TrainingScreen extends StatefulWidget {
  final Map<String, dynamic> trainingSession;
  final void Function(Map<String, int>)? onEvaluationSaved;

  const TrainingScreen({
    super.key,
    required this.trainingSession,
    this.onEvaluationSaved, // se inicializa en el constructor
  });

  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  double _diversionCompromiso = 75.0;
  double _aprendizajeHabilidades = 85.0;
  double _efectividadTactica = 60.0;

  late List<Map<String, dynamic>> _exerciseSections;

  @override
  void initState() {
    super.initState();
    final rawExercises = widget.trainingSession['exercises'];
    if (rawExercises != null) {
      _exerciseSections = (rawExercises as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } else {
      _exerciseSections =
          _generateExercises(widget.trainingSession['objective'] as String);
    }

    // Inicializar sliders si ya hay evaluación guardada
    final rawEval =
        widget.trainingSession['evaluation'] as Map<String, dynamic>? ?? {};
    final eval =
        rawEval.map((key, value) => MapEntry(key, (value as num).toInt()));

    _diversionCompromiso = eval['Diversion']?.toDouble() ?? 75.0;
    _aprendizajeHabilidades = eval['Aprendizaje']?.toDouble() ?? 85.0;
    _efectividadTactica = eval['Efectividad']?.toDouble() ?? 60.0;
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.trainingSession['date'] as DateTime;
    final objective = widget.trainingSession['objective'] as String;
    final duration = widget.trainingSession['duration'] as String;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, {
            'date': widget.trainingSession['date'],
            'objective': widget.trainingSession['objective'],
            'duration': widget.trainingSession['duration'],
            'description': widget.trainingSession['description'] ?? '',
            'exercises': _exerciseSections,
            'evaluation': widget.trainingSession['evaluation'] ?? {},
          }),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la sesión con botón de editar
            Row(
              children: [
                Expanded(
                  child: Text(
                    objective,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black, size: 20),
                  onPressed: () async {
                    // Abrir pantalla de edición
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SessionEditorScreen(
                          session: {
                            "title": objective,
                            "description":
                                widget.trainingSession['description'] ?? "",
                            "categories": _exerciseSections,
                          },
                        ),
                      ),
                    );

                    if (result != null) {
                      setState(() {
                        widget.trainingSession['objective'] = result['title'];
                        widget.trainingSession['description'] =
                            result['description'];
                        _exerciseSections = List<Map<String, dynamic>>.from(
                            result['categories']);
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(date),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                duration,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 24),

            // Secciones de ejercicios
            ..._exerciseSections
                .map((section) => _buildExerciseSection(section))
                .toList(),

            const SizedBox(height: 24),

            // Evaluación de la sesión
            _buildEvaluationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseSection(Map<String, dynamic> section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section['title'],
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        ...section['exercises'].map<Widget>((exercise) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text(exercise['name'],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTypeColor(exercise['type']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        exercise['type'],
                        style: TextStyle(
                          fontSize: 12,
                          color: _getTypeColor(exercise['type']),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(exercise['description'] ?? 'Sin descripción'),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEvaluationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.orange[600], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Evaluación de la Sesión',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Califica la efectividad de la sesión de entrenamiento.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          _buildSlider('Diversión y Compromiso', _diversionCompromiso,
              (v) => setState(() => _diversionCompromiso = v)),
          const SizedBox(height: 16),
          _buildSlider(
              'Aprendizaje y Desarrollo de Habilidades',
              _aprendizajeHabilidades,
              (v) => setState(() => _aprendizajeHabilidades = v)),
          const SizedBox(height: 16),
          _buildSlider('Efectividad Táctica', _efectividadTactica,
              (v) => setState(() => _efectividadTactica = v)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final evaluation = {
                  'diversionCompromiso': _diversionCompromiso.round(),
                  'aprendizajeHabilidades': _aprendizajeHabilidades.round(),
                  'efectividadTactica': _efectividadTactica.round(),
                  'date': DateTime.now(),
                };
                print("✅ Evaluación guardada: $evaluation");

                // Llamamos al callback si existe
                widget.onEvaluationSaved?.call({
                  'Diversion': evaluation['diversionCompromiso'] as int,
                  'Aprendizaje': evaluation['aprendizajeHabilidades'] as int,
                  'Efectividad': evaluation['efectividadTactica'] as int,
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Evaluación guardada con éxito'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Guardar Evaluación',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
      String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text('${value.round()}%',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal)),
        ]),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.teal[300],
            inactiveTrackColor: Colors.grey[300],
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayColor: Colors.teal[100],
            trackHeight: 6,
          ),
          child: Slider(value: value, min: 0, max: 100, onChanged: onChanged),
        ),
      ],
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'calentamiento':
        return Colors.orange;
      case 'técnica':
        return Colors.blue;
      case 'colectivo':
        return Colors.green;
      case 'partido':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final days = [
      'domingo',
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado'
    ];
    final months = [
      '',
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    return '${days[date.weekday % 7]}, ${date.day} de ${months[date.month]} de ${date.year}';
  }

  List<Map<String, dynamic>> _generateExercises(String objective) {
    return [
      {
        'title': 'Calentamiento',
        'exercises': [
          {
            'name': 'Ejercicio Inicial',
            'type': 'Calentamiento',
            'description': 'Descripción del calentamiento'
          }
        ]
      }
    ];
  }
}
