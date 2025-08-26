import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_screen.dart';
import '../widgets/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _userName = 'Coach';
  String _userTeam = 'U12 Escorpiones';
  String _userAvatar = 'https://i.pravatar.cc/150?img=3';

  final List<Map<String, dynamic>> _trainingSessions = [
    {'date': DateTime.now().add(const Duration(days: 1)), 'objective': 'Dribbling y pases', 'duration': '1h'},
    {'date': DateTime.now().add(const Duration(days: 3)), 'objective': 'Tiro y defensa', 'duration': '1h 30min'},
  ];

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = List.generate(4, (_) => const Center(child: CircularProgressIndicator()));
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Coach';
      _userTeam = prefs.getString('team') ?? 'U12 Escorpiones';
      _userAvatar = prefs.getString('avatar') ?? 'https://i.pravatar.cc/150?img=3';

      _screens = [
        _dashboardScreen(),
        const Center(child: Text('Calendar')),
        const Center(child: Text('Community')),
        ProfileScreen(onProfileUpdated: _loadUserData),
      ];
    });
  }

  Widget _dashboardScreen() {
    final upcomingSessions = _trainingSessions
        .where((s) => (s['date'] as DateTime).isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 32, backgroundImage: NetworkImage(_userAvatar)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Bienvenido, $_userName!',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _userTeam,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Planificar para $_userTeam',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Usa la IA o planifica tu próximo entrenamiento manualmente.'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/recommendations'),
                          child: const Text('Recomendaciones IA'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushNamed(context, '/calendar'),
                          child: const Text('Planificar Manualmente'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Próximos Entrenamientos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          upcomingSessions.isNotEmpty
              ? Column(
                  children: upcomingSessions.map((session) {
                    final date = session['date'] as DateTime;
                    return Card(
                      child: ListTile(
                        title: Text(session['objective']),
                        subtitle: Text('${date.day}/${date.month} | ${session['duration']}'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {},
                      ),
                    );
                  }).toList(),
                )
              : Column(
                  children: [
                    const SizedBox(height: 16),
                    Text('No hay próximas sesiones para $_userTeam.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/calendar'),
                      child: const Text('Crear una sesión'),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

