/*
import 'dart:async';

import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pika_client_flutter/gamemain.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pikachu Volleyball',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  double _offsetX = 0.0;
  double _offsetY = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start a timer to update the background position
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _offsetX -= 1.0; // Adjust speed as needed
        _offsetY -= 1.0; // Adjust speed as needed

        // Check if offsets exceed certain limits to reset and create infinite scrolling effect
        if (_offsetX <= -1000) {
          _offsetX = 0.0;
        }
        if (_offsetY <= -1000) {
          _offsetY = 0.0;
          print("reset");
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 10), // Adjust duration as needed
              transform: Matrix4.translationValues(_offsetX, _offsetY, 0) *
                  Matrix4.diagonal3Values(10.0, 10.0, 1.0),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  scale: 10,
                  image: AssetImage(
                      'assets/Bitmap120.bmp'), // Your background image path
                  fit: BoxFit
                      .scaleDown, // Adjust this based on your image size and requirements
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              Center(
                child: Text(
                  "포켓몬스터",
                  style: TextStyle(
                      fontFamily: 'RetroFont',
                      color: Colors.blue.brighten(0.6),
                      fontSize: 24,
                      fontWeight: FontWeight.w400),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const Center(
                child: Text("피카츄배구 온라인",
                    style: TextStyle(
                        fontFamily: 'RetroFont',
                        color: Colors.yellow,
                        fontSize: 48,
                        fontWeight: FontWeight.w500)),
              ),
              const SizedBox(
                height: 50,
              ),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.yellowAccent.withOpacity(0),
                    backgroundColor: Colors.yellowAccent.withOpacity(0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MainScreen()),
                    );
                  },
                  child: Text(
                    '구글로 로그인',
                    style: TextStyle(
                      fontFamily: 'RetroFont',
                      color: Colors.blueAccent[400],
                    ),
                  ),
                ),
              ),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.yellowAccent.withOpacity(0),
                    backgroundColor: Colors.yellowAccent.withOpacity(0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MainScreen()),
                    );
                  },
                  child: Text(
                    '카카오로 로그인',
                    style: TextStyle(
                      fontFamily: 'RetroFont',
                      color: Colors.blueAccent[400],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('피카츄 배구 온라인',
              style: TextStyle(fontFamily: 'RetroFont')),
          bottom: const TabBar(
            labelStyle: TextStyle(
              fontFamily: 'RetroFont',
              color: Colors.yellow,
            ),
            tabs: [
              Tab(
                text: '일반 게임',
              ),
              Tab(text: '랭킹'),
              Tab(text: '친구 목록'),
              Tab(text: '내 정보 상세보기'),
            ],
          ),
        ),
        body: Row(
          children: [
            const Expanded(
              flex: 1,
              child: UserProfile(),
            ),
            Expanded(
              flex: 2,
              child: TabBarView(
                children: [
                  GameRoomList(),
                  const RankingList(),
                  const FriendList(),
                  const UserDetail(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.yellow.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: null,
          ),
          const SizedBox(height: 16),
          const Text('User Name',
              style: TextStyle(fontSize: 24, fontFamily: 'RetroFont')),
          const Text('user@example.com',
              style: TextStyle(fontSize: 16, fontFamily: 'RetroFont')),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              // Show the waiting dialog immediately
              showDialog(
                context: context,
                builder: (context) => const RankGameWaiting(),
              );

              // Delay the navigation to the game screen
              Future.delayed(const Duration(seconds: 10), () {
                Navigator.pop(context); // Close the waiting dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const VolleyballGameWidget(role: 'visitor'),
                  ),
                );
              });
            },
            child: const Text(
              '랭크 게임 시작',
              style: TextStyle(
                fontFamily: 'RetroFont',
                color: Colors.yellow,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GameRoomList extends StatelessWidget {
  final List<GameRoom> gameRooms = [
    GameRoom('Room 1', 'User A'),
    GameRoom('Room 2', 'User B'),
    GameRoom('Room 3', 'User C'),
  ];

  GameRoomList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: gameRooms.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(gameRooms[index].name,
              style: const TextStyle(fontFamily: 'RetroFont')),
          subtitle: Text('Created by: ${gameRooms[index].creator}',
              style: const TextStyle(fontFamily: 'RetroFont')),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => GameRoomDetail(room: gameRooms[index]),
            );
          },
        );
      },
    );
  }
}

class RankingList extends StatelessWidget {
  const RankingList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text('랭킹 목록', style: TextStyle(fontFamily: 'RetroFont')));
  }
}

class FriendList extends StatelessWidget {
  const FriendList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text('친구 목록', style: TextStyle(fontFamily: 'RetroFont')));
  }
}

class UserDetail extends StatelessWidget {
  const UserDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text('내 정보 상세보기', style: TextStyle(fontFamily: 'RetroFont')));
  }
}

class GameRoomDetail extends StatelessWidget {
  final GameRoom room;

  const GameRoomDetail({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(room.name, style: const TextStyle(fontFamily: 'RetroFont')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Creator: ${room.creator}',
              style: const TextStyle(fontFamily: 'RetroFont')),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close', style: TextStyle(fontFamily: 'RetroFont')),
        ),
      ],
    );
  }
}

class GameRoom {
  final String name;
  final String creator;

  GameRoom(this.name, this.creator);
}

class RankGameWaiting extends StatefulWidget {
  const RankGameWaiting({super.key});

  @override
  State<RankGameWaiting> createState() => _RankGameWaitingState();
}

class _RankGameWaitingState extends State<RankGameWaiting>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "매칭중...",
        style: TextStyle(fontFamily: 'RetroFont'),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("실력에 맞는 상대방을 찾는 중 입니다...",
              style: TextStyle(fontFamily: 'RetroFont')),
          const SizedBox(
            height: 20,
          ),
          const CircularProgressIndicator(),
          const SizedBox(
            height: 20,
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Text(
                '${(60 * _controller.value).toInt()}초 경과',
                style: const TextStyle(fontFamily: 'RetroFont'),
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('그만두기', style: TextStyle(fontFamily: 'RetroFont')),
        ),
      ],
    );
  }
}
*/