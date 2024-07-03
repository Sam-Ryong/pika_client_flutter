import 'package:flame/src/gestures/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:flame/game.dart";
import 'package:pika_client_flutter/hostgame.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  final VolleyballGame game = VolleyballGame();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      /*
      onPanUpdate: (details) {
        game.onPanUpdate(details.delta);
      },
      */
      child: Stack(
        children: [
          GameWidget(game: game),
          Positioned(
            left: 20,
            bottom: 20,
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
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            game.movePlayer1Left();
          },
          child: Container(
            width: 50,
            height: 50,
            color: Colors.blue,
            child: Icon(Icons.arrow_back),
          ),
        ),
        SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            game.movePlayer1Right();
          },
          child: Container(
            width: 50,
            height: 50,
            color: Colors.blue,
            child: Icon(Icons.arrow_forward),
          ),
        ),
        SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            game.movePlayer1Up();
          },
          child: Container(
            width: 50,
            height: 50,
            color: Colors.blue,
            child: Icon(Icons.arrow_upward),
          ),
        ),
        SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            game.movePlayer1Down();
          },
          child: Container(
            width: 50,
            height: 50,
            color: Colors.blue,
            child: Icon(Icons.arrow_downward),
          ),
        ),
      ],
    );
  }
}
