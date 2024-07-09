import 'package:flutter/material.dart';
import 'package:pika_client_flutter/controller/server_controller.dart';
import 'package:pika_client_flutter/gamemain.dart';
import 'package:pika_client_flutter/hostgame.dart';

class VisitorEnterDialog extends StatelessWidget {
  const VisitorEnterDialog(
      {super.key,
      required this.game,
      required this.hostId,
      required this.myId,
      required this.dialog,
      required this.id});

  final VolleyballGame game;
  final String hostId;
  final String myId;
  final VolleyballGameWidgetState dialog;
  final String id;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getData('http://192.168.0.103:3001/api/user/$id'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            dynamic userinfo = snapshot.data;
            String name = userinfo["name"];
            int win = userinfo["win"];
            int lose = userinfo["lose"];
            String tier = userinfo["tier"];
            int tierPoint = userinfo["tierPoint"];
            return AlertDialog(
              title: Text('$name님의 입장 요청'),
              content: Text('$win승 $lose패 $tier $tierPoint p'),
              actions: [
                TextButton(
                  onPressed: () => {setPermission(game, true, context)},
                  child: Text('승락'),
                ),
                TextButton(
                  onPressed: () => {setPermission(game, false, context)},
                  child: Text('거절'),
                ),
              ],
            );
          }
        });
  }

  void setPermission(
      VolleyballGame game, bool permission, BuildContext context) {
    game.webSocketManager.handleRoomAccess(hostId, myId, permission);
    Navigator.of(context, rootNavigator: true).pop();
    dialog.closeDialog();
  }
}

class WaitingDialog extends StatelessWidget {
  const WaitingDialog(
      {super.key,
      required this.game,
      required this.hostId,
      required this.myId,
      required this.role});
  final VolleyballGame game;
  final String hostId;
  final String myId;
  final String role;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('대기중'),
      content: Column(
        children: [
          const CircularProgressIndicator(),
          role == "host"
              ? const Text('상대방의 입장을 대기합니다')
              : const Text("상대방의 수락을 대기합니다."),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => {game.webSocketManager.outRoom(hostId, myId)},
          child: Text('나가기'),
        ),
      ],
    );
  }
}
