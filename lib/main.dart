import 'dart:async';

import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pika_client_flutter/controller/light_web_socket_controller.dart';
import 'package:pika_client_flutter/controller/server_controller.dart';
import 'package:pika_client_flutter/gamemain.dart';
import 'package:pika_client_flutter/google/samplecode.dart';

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
                        color: const Color.fromARGB(255, 255, 41, 226),
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
                  onPressed: () async {
                    final GoogleSignInAccount? user = await signInWithGoogle();
                    if (user != null) {
                      await postData(
                        "http://54.180.157.115:3001/api/user",
                        {
                          "id": user.id,
                          "name": user.displayName,
                          "email": user.email,
                          "photoUrl": user.photoUrl
                        },
                      );
                    }
                    final userinfo = await getData(
                        "http://54.180.157.115:3001/api/user/${user!.id}");
                    if (userinfo != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MainScreen(userinfo: userinfo)),
                      );
                    }
                  },
                  child: Text(
                    '구글로 로그인',
                    style: TextStyle(
                      fontFamily: 'RetroFont',
                      color: const Color.fromARGB(255, 255, 41, 226),
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
                      MaterialPageRoute(builder: (context) => MainScreen()),
                    );
                  },
                  child: Text(
                    'Remade By 2019102243 홍승표',
                    style: TextStyle(
                      fontFamily: 'RetroFont',
                      //color: Colors.blueAccent[400],
                      color: const Color.fromARGB(255, 255, 41, 226),
                      fontSize: 12,
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

// ignore: must_be_immutable
class MainScreen extends StatelessWidget {
  final GoogleSignInAccount? user;
  final dynamic userinfo;
  final GameRoomList gameRoomList = GameRoomList();
  late LightWebSocketController lightWebSocketController;
  MainScreen({super.key, this.user, this.userinfo});

  @override
  Widget build(BuildContext context) {
    lightWebSocketController =
        LightWebSocketController('ws://54.180.157.115:3000', gameRoomList);

    gameRoomList.lightWebSocketController = lightWebSocketController;
    gameRoomList.userinfo = userinfo;
    lightWebSocketController.getRooms("temp");
    return DefaultTabController(
      length: 3,
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
              Tab(text: '랭킹'),
              Tab(text: '일반 게임'),
              Tab(text: '나의 랭킹 정보'),
            ],
          ),
        ),
        body: Row(
          children: [
            Expanded(
              flex: 1,
              child: UserProfile(
                userinfo: userinfo,
              ),
            ),
            Expanded(
              flex: 2,
              child: TabBarView(
                children: [
                  const RankingList(),
                  gameRoomList,
                  UserDetail(
                    userinfo: userinfo,
                  ),
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
  final dynamic userinfo;
  const UserProfile({super.key, required this.userinfo});
  //print('name = ${googleUser.displayName}');
  //print('email = ${googleUser.email}');
  //print('id = ${googleUser.id}');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.yellow.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: (userinfo?["photoUrl"] != null)
                ? NetworkImage(userinfo?["photoUrl"])
                : null,
          ),
          const SizedBox(height: 10),
          Text('${userinfo?["name"]}',
              style: const TextStyle(fontSize: 10, fontFamily: 'RetroFont')),
          Text('${userinfo?["email"]}',
              style: const TextStyle(fontSize: 10, fontFamily: 'RetroFont')),
          const SizedBox(height: 10),
          Text(
              '${userinfo?["win"]}승 ${userinfo?["lose"]}패 승률 ${userinfo?["win"] + userinfo?["lose"] != 0 ? (userinfo?["win"] / (userinfo?["win"] + userinfo?["lose"]) * 100) : 0} %',
              style: const TextStyle(fontSize: 14, fontFamily: 'RetroFont')),
          const SizedBox(height: 10),
          Text('${userinfo?["tier"]} ${userinfo?["tierPoint"]}p',
              style: const TextStyle(fontSize: 14, fontFamily: 'RetroFont')),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VolleyballGameWidget(
                    role: 'host',
                    myId: userinfo["id"],
                    hostId: userinfo["id"],
                    userinfo: userinfo,
                  ),
                ),
              );
            },
            child: const Text(
              '방 만들기',
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

// ignore: must_be_immutable
class GameRoomList extends StatelessWidget {
  List<GameRoom> gameRooms = [];
  dynamic userinfo;
  GameRoomList({super.key, this.userinfo});
  late LightWebSocketController lightWebSocketController;

  @override
  Widget build(BuildContext context) {
    lightWebSocketController.getRooms("1234");
    return gameRooms.isNotEmpty
        ? ListView.builder(
            itemCount: gameRooms.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text("${gameRooms[index].name}의 게임",
                    style: const TextStyle(fontFamily: 'RetroFont')),
                subtitle: Text(
                    '${gameRooms[index].win}승 ${gameRooms[index].win}패 ${gameRooms[index].tier} ${gameRooms[index].tierPoint}',
                    style: const TextStyle(fontFamily: 'RetroFont')),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => GameRoomDetail(
                      room: gameRooms[index],
                      userinfo: userinfo,
                    ),
                  );
                },
              );
            },
          )
        : const Center(child: CircularProgressIndicator());
  }

  void setGameRooms(List<dynamic> gameRoomList) async {
    List<GameRoom> temp = [];

    for (int i = 0; i < gameRoomList.length; i++) {
      dynamic userinfo = await getData(
          "http://54.180.157.115:3001/api/user/${gameRoomList[i]}");
      temp.add(GameRoom(userinfo["name"], userinfo["win"], userinfo["lose"],
          userinfo["tier"], userinfo["tierPoint"], userinfo["id"]));
    }
    gameRooms = temp;
  }
}

class RankingList extends StatelessWidget {
  const RankingList({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getData("http://54.180.157.115:3001/api/rank"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        } else {
          // 데이터를 성공적으로 가져온 경우
          List<dynamic> data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              var item = data[index];
              return ListTile(
                leading: CircleAvatar(child: Text((index + 1).toString())),
                title: Text(item['name']),
                subtitle: Text(
                    '${item['win']}승 ${item['win']}패 승률 ${item["win"] + item["lose"] != 0 ? (item["win"] / (item["win"] + item["lose"]) * 100) : 0} % ${item['tierPoint']} point'),
                trailing: Text(item['tier']),
              );
            },
          );
        }
      },
    );
  }
}

class UserDetail extends StatelessWidget {
  const UserDetail({super.key, this.userinfo});
  final dynamic userinfo;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          getData("http://54.180.157.115:3001/api/rank/user/${userinfo["id"]}"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        } else {
          // 데이터를 성공적으로 가져온 경우
          List<dynamic> data = snapshot.data!;
          int rank = data[0];
          return ListView.builder(
            itemCount: data[1].length,
            itemBuilder: (context, index) {
              var item = data[1][index];

              return ListTile(
                leading:
                    CircleAvatar(child: Text((rank + index + 1).toString())),
                title: Text(item['name']),
                subtitle: Text(
                    '${item['win']}승 ${item['win']}패 승률 ${item["win"] + item["lose"] != 0 ? (item["win"] / (item["win"] + item["lose"]) * 100) : 0} % ${item['tierPoint']} point'),
                trailing: Text(item['tier']),
              );
            },
          );
        }
      },
    );
  }
}

class GameRoomDetail extends StatelessWidget {
  final GameRoom room;
  final dynamic userinfo;

  const GameRoomDetail({super.key, required this.room, this.userinfo});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(room.name, style: const TextStyle(fontFamily: 'RetroFont')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Creator: ${room.name}',
              style: const TextStyle(fontFamily: 'RetroFont')),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VolleyballGameWidget(
                  role: 'visitor',
                  myId: userinfo["id"],
                  hostId: room.id,
                  userinfo: userinfo,
                ),
              ),
            );
          },
          child: const Text('입장하기', style: TextStyle(fontFamily: 'RetroFont')),
        ),
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
  final String id;
  final String name;
  final int win;
  final int lose;
  final String tier;
  final int tierPoint;

  GameRoom(this.name, this.win, this.lose, this.tier, this.tierPoint, this.id);
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
