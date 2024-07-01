import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'volleyball_game.dart';

void main() {
  runApp(
    GameWidget(
      game: VolleyballGame(),
    ),
  );
}
