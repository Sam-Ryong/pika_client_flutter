import 'package:flutter/material.dart';
import "package:flame/game.dart";
import 'package:pika_client_flutter/hostgame.dart';
// import 'package:pika_client_flutter/visitorgame.dart';

class VolleyballGameWidget extends StatelessWidget {
  final String role;
  final String myId;
  final String hostId;

  const VolleyballGameWidget(
      {super.key,
      required this.role,
      required this.myId,
      required this.hostId});

  @override
  Widget build(BuildContext context) {
    final VolleyballGame game = VolleyballGame(role, myId, hostId);
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        /*
        onPanUpdate: (details) {
          game.onPanUpdate(details.delta);
        },
        */
        child: Stack(
          children: [
            GameWidget(
              game: game,
            ),
          ],
        ),
      ),
    );
  }
}
