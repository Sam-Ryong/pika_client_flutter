import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:flame/game.dart";
import 'package:pika_client_flutter/hostgame.dart';
// import 'package:pika_client_flutter/visitorgame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volleyball Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VolleyballGameWidget(role: "host"),
                  ),
                );
              },
              child: Text('Start Game as Host'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VolleyballGameWidget(role: "visitor"),
                  ),
                );
              },
              child: Text('Start Game as Visitor'),
            ),
          ],
        ),
      ),
    );
  }
}

class VolleyballGameWidget extends StatelessWidget {
  final String role;

  VolleyballGameWidget({required this.role});

  @override
  Widget build(BuildContext context) {
    final VolleyballGame game = VolleyballGame(role);
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
