import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:flame/game.dart";
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:pika_client_flutter/hostgame.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen;
  Flame.device.setLandscape();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volleyball Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Center(
          child: VolleyballGameWidget(),
        ),
      ),
    );
  }
}

class VolleyballGameWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final VolleyballGame game = VolleyballGame();
    return GestureDetector(
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
          Positioned(
            right: 100,
            bottom: 50,
            child: DirectionControls(game: game),
          ),
        ],
      ),
    );
  }
}

class DirectionControls extends StatelessWidget {
  final VolleyballGame game;

  DirectionControls({required this.game});

  @override
  Widget build(BuildContext context) {
    return Joystick(
      includeInitialAnimation: false,
      base: JoystickBase(
        size: 100,
        decoration: JoystickBaseDecoration(
          color: Colors.grey.withOpacity(0.5),
        ),
      ),
      stick: JoystickStick(
        size: 45,
        decoration: JoystickStickDecoration(
            color: Colors.grey, shadowColor: Colors.yellow.withOpacity(0.5)),
      ),
      listener: (details) {
        if (details.x > 0.5) {
          game.movePlayer1Right();
        }
        if (details.x < -0.5) {
          game.movePlayer1Left();
        }
        if (details.y < -0.5) {
          game.movePlayer1Up();
        }
        if (details.x <= 0.5 && details.x >= -0.5 && details.y >= -0.5) {
          game.nothing();
        }
      },
    );
  }
}
