import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:flame/game.dart";
import 'package:pika_client_flutter/hostgame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
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
        ],
      ),
    );
  }
}
