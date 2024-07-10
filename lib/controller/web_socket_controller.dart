import 'dart:convert';

import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pika_client_flutter/controller/server_controller.dart';
import 'package:pika_client_flutter/hostgame.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketController {
  late WebSocketChannel channel;

  WebSocketController(String url, VolleyballGame game) {
    channel = WebSocketChannel.connect(Uri.parse(url));
    channel.stream.listen(
      (message) {
        Map<String, dynamic> data = jsonDecode(message);
        String type = data["type"];
        if (type == "ballInfo") {
          game.ball.setRemoteInfo(data["position"], data["velocity"]);
        } else if (type == "ballState") {
          game.ball.setRemoteState(data["state"]);
        } else if (type == "playerInfo") {
          game.visitor.setPlayerPosition(data["position"]);
          game.visitor.setPlayerState(data["current"]);
        } else if (type == "playerDir") {
          game.visitor.setPlayerDirection(data["direction"]);
        } else if (type == "ready") {
          handleReady(game, data["visitor"]);
        } else if (type == "point") {
          if (data["role"] == "host") {
            game.hostScore.increase();
          } else if (data["role"] == "visitor") {
            game.visitorScore.increase();
          }
        } else if (type == "sound") {
          if (game.playSounds) {
            FlameAudio.play("${data["sound"]}.wav", volume: game.soundVolume);
          }
        } else if (type == "noRoom") {
          handleNoRoom(game);
        } else if (type == "fullRoom") {
          handleFullRoom(game);
        } else if (type == "roomAccess") {
          game.dialog.whenVisitorEnter(data["visitor"], game);
        } else if (type == "permission") {
          handlePermission(data, game);
        } else if (type == "outDone") {
          game.dialog.closeDialog();
          game.dialog.exitGame();
        } else if (type == "giveUp") {
          handleGiveUp(game);
        }
      },
      onError: (error) {},
      onDone: () {},
    );
  }

  void makeRoom(String hostId, VolleyballGame game) {
    game.dialog.showWaitingDialog(game);
    Map<String, dynamic> data = {
      'type': "makeRoom",
      'host': hostId,
    };
    channel.sink.add(jsonEncode(data));
  }

  void outRoom(String hostId, String myId, VolleyballGame game) {
    Map<String, dynamic> data = {
      'type': "outRoom",
      'host': hostId,
      "visitor": myId,
    };
    try {
      channel.sink.add(jsonEncode(data));
    } catch (err) {
      game.dialog.closeDialog();
      game.dialog.exitGame();
    }
  }

  void enterRoom(String hostId, String myId, VolleyballGame game) {
    game.dialog.showWaitingDialog(game);
    Map<String, dynamic> data = {
      'type': "enterRoom",
      'host': hostId,
      "visitor": myId,
    };
    channel.sink.add(jsonEncode(data));
  }

  void sendPlayerInfo(
      String hostId, String myId, Vector2 position, dynamic current) {
    String pos = "$position";
    String cur = "$current".substring(12);
    Map<String, dynamic> data = {
      'type': "playerInfo",
      'host': hostId,
      'visitor': myId,
      "position": pos,
      "current": cur,
    };
    channel.sink.add(jsonEncode(data));
  }

  void sendSound(VolleyballGame game, String sound) {
    Map<String, dynamic> data = {
      'type': "sound",
      'host': game.hostId,
      'visitor': game.myId,
      "sound": sound,
    };
    channel.sink.add(jsonEncode(data));
  }

  void sendPlayerDirection(String hostId, String myId, int isFacingRight) {
    String dir = "$isFacingRight";
    Map<String, dynamic> data = {
      'type': "playerDir",
      'host': hostId,
      'visitor': myId,
      "direction": dir,
    };
    channel.sink.add(jsonEncode(data));
  }

  void sendBallInfo(
      String hostId, String myId, Vector2 position, Vector2 velocity) {
    String pos = "$position";
    String vel = "$velocity";
    Map<String, dynamic> data = {
      'type': "ballInfo",
      'host': hostId,
      'visitor': myId,
      "position": pos,
      "velocity": vel,
    };
    channel.sink.add(jsonEncode(data));
  }

  void sendBallState(String hostId, String myId, String state) {
    String st = state;
    Map<String, dynamic> data = {
      'type': "ballState",
      'host': hostId,
      'visitor': myId,
      "state": st,
    };
    channel.sink.add(jsonEncode(data));
  }

  void sendPoint(String hostId, String myId, String role) {
    Map<String, dynamic> data = {
      'type': "point",
      'host': hostId,
      'visitor': myId,
      'role': role,
    };
    channel.sink.add(jsonEncode(data));
  }

  void close() {
    channel.sink.close();
  }

  //handler 들..
  void handleGiveUp(VolleyballGame game) {
    postData(
      "http://54.180.157.115/api/game",
      {
        "winner": game.myId,
        "loser": game.enemyId,
      },
    );
    game.dialog.setIsErrorAndReason("상대방이 경기를 강제 종료했습니다. 몰수 승리 판정입니다.", game);
  }

  void handleNoRoom(VolleyballGame game) {
    game.dialog.closeDialog();
    game.dialog.setIsErrorAndReason("방이 그 순간 삭제 되었나봅니다.", game);
  }

  void handleFullRoom(VolleyballGame game) {
    game.dialog.closeDialog();
    game.dialog.setIsErrorAndReason("방이 게임중이거나 꽉 찼습니다.", game);
  }

  void handleRoomAccess(String hostId, String myId, bool permission) {
    Map<String, dynamic> decision = {
      'type': "permission",
      'host': hostId,
      'visitor': myId,
      'permission': permission
    };
    channel.sink.add(jsonEncode(decision));
  }

  void handlePermission(Map<String, dynamic> data, VolleyballGame game) {
    bool permission = data['permission'];
    if (permission) {
      Map<String, dynamic> ready = {
        'type': "ready",
        'host': data["host"],
        'visitor': game.myId,
      };
      channel.sink.add(jsonEncode(ready));
      game.dialog.closeDialog();
      game.ready1.makeLarge();
      Future.delayed(const Duration(milliseconds: 1500), () {
        game.ready1.reset();
        game.host.respawn();
        game.ball.respawn();
        game.slow = 1;
      });
      game.isVisitorReady = true;
    } else {
      game.dialog.setIsBanned(game);
    }
  }

  void handleReady(VolleyballGame game, String id) {
    game.isVisitorReady = true;
    game.enemyId = id;
    game.ready1.makeLarge();
    Future.delayed(const Duration(milliseconds: 1500), () {
      game.ready1.reset();
      game.host.respawn();
      game.ball.respawn();
      game.slow = 1;
    });
  }
}
