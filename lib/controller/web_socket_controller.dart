import 'package:flame/components.dart';
import 'package:pika_client_flutter/components/ball.dart';
import 'package:pika_client_flutter/components/dummy_player.dart';
import 'package:pika_client_flutter/hostgame.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketController {
  late WebSocketChannel channel;

  WebSocketController(
      String url, PikaDummyPlayer visitor, PikaBall ball, VolleyballGame game) {
    channel = WebSocketChannel.connect(Uri.parse(url));
    channel.stream.listen(
      (message) {
        if (message[0] == "A" || message[0] == "B") {
          ball.setRemoteInfo(message);
        } else if (message[0] == "S") {
          ball.setRemoteState(message.substring(1));
        } else if (message[0] == "0") {
          visitor.setPlayerPosition(message.substring(1));
        } else if (message[0] == "2") {
          visitor.setPlayerDirection(message.substring(1));
        } else if (message[0] == "1") {
          visitor.setPlayerState(message.substring(13));
        } else if (message == "ready") {
          game.isVisitorReady = true;
          game.ready1.makeLarge();
          Future.delayed(const Duration(milliseconds: 1500), () {
            game.ready1.reset();
            game.host.respawn();
            game.ball.respawn();
            game.slow = 1;
          });
        } else if (message == "H") {
          game.hostScore.increase();
        } else if (message == "V") {
          game.visitorScore.increase();
        }
      },
      onError: (error) {},
      onDone: () {},
    );
  }

  void sendPlayerInfo(Vector2 position, dynamic current) {
    String pos = "0$position";
    String cur = "1$current";

    channel.sink.add(pos);
    channel.sink.add(cur);
  }

  void sendPlayerDirection(int isFacingRight) {
    String dir = "2$isFacingRight";
    channel.sink.add(dir);
  }

  void sendBallInfo(Vector2 position, Vector2 velocity) {
    String pos = "A$position";
    String vel = "B$velocity";
    channel.sink.add(pos);
    channel.sink.add(vel);
  }

  void sendBallState(String state) {
    String st = "S$state";
    channel.sink.add(st);
  }

  void sendReady(String ready) {
    channel.sink.add(ready);
  }

  void sendPoint(String role) {
    channel.sink.add(role);
  }

  void close() {
    channel.sink.close();
  }
}
