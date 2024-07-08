import 'dart:convert';

import 'package:flame/components.dart';
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
          handleReady(game);
        } else if (type == "point") {
          if (data["role"] == "host") {
            game.hostScore.increase();
          } else if (data["role"] == "visitor") {
            game.visitorScore.increase();
          }
        } else if (type == "visitorOut") {
          handleVisitorOut(data);
        } else if (type == "noRoom") {
          handleNoRoom(data);
        } else if (type == "fullRoom") {
          handleFullRoom(data);
        } else if (type == "roomAccess") {
          handleRoomAccess(data);
        } else if (type == "permission") {
          handlePermission(data, game);
        }
      },
      onError: (error) {},
      onDone: () {},
    );
  }

  void makeRoom(String hostId) {
    Map<String, dynamic> data = {
      'type': "makeRoom",
      'host': hostId,
    };
    channel.sink.add(jsonEncode(data));
  }

  void outRoom(String hostId, String myId) {
    Map<String, dynamic> data = {
      'type': "outRoom",
      'host': hostId,
      "visitor": myId,
    };
    channel.sink.add(jsonEncode(data));
  }

  void enterRoom(String hostId, String myId) {
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
    String cur = "$current";
    Map<String, dynamic> data = {
      'type': "playerInfo",
      'host': hostId,
      'visitor': myId,
      "position": pos,
      "current": cur,
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
  void handleVisitorOut(Map<String, dynamic> data) {}

  void handleNoRoom(Map<String, dynamic> data) {}

  void handleFullRoom(Map<String, dynamic> data) {}

  void handleRoomAccess(Map<String, dynamic> data) {
    bool permission = true;
    Map<String, dynamic> decision = {
      'type': "permission",
      'host': data["host"],
      'visitor': data["visitor"],
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
        'visitor': data["visitor"],
      };
      channel.sink.add(jsonEncode(ready));

      game.ready1.makeLarge();
      Future.delayed(const Duration(milliseconds: 1500), () {
        game.ready1.reset();
        game.host.respawn();
        game.ball.respawn();
        game.slow = 1;
      });
      game.isVisitorReady = true;
    } else {
      outRoom(data["host"], data["visitor"]);
    }
  }

  void handleReady(VolleyballGame game) {
    game.isVisitorReady = true;
    game.ready1.makeLarge();
    Future.delayed(const Duration(milliseconds: 1500), () {
      game.ready1.reset();
      game.host.respawn();
      game.ball.respawn();
      game.slow = 1;
    });
  }
}
