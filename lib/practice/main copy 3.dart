import 'package:flutter/material.dart';
import 'package:pika_client_flutter/practice/screens/home_screen.dart';
import 'package:pika_client_flutter/practice/services/api_service.dart';

void main() {
  ApiService.getTodaysToons();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}
