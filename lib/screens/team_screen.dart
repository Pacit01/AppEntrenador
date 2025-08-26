import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/team.dart';
import '../services/mock_service.dart';
import '../widgets/player_card.dart';

class TeamScreen extends StatelessWidget {
  final Team team;
  final MockService mockService = MockService();

  TeamScreen({required this.team});

  @override
  Widget build(BuildContext context) {
    List<Player> teamPlayers = mockService.players.where((p) => p.teamId == team.id).toList();

    return Scaffold(
      appBar: AppBar(title: Text(team.name)),
      body: ListView.builder(
        itemCount: teamPlayers.length,
        itemBuilder: (context, index) => PlayerCard(player: teamPlayers[index]),
      ),
    );
  }
}
