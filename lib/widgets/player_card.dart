import 'package:flutter/material.dart';
import '../models/player.dart';

class PlayerCard extends StatelessWidget {
  final Player player;

  PlayerCard({required this.player});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(player.name),
        subtitle: Text('Jersey: ${player.jersey}'),
        trailing: Icon(Icons.favorite_border),
      ),
    );
  }
}
