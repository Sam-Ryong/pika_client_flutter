import 'package:flame/components.dart';
import 'package:pika_client_flutter/components/ball.dart';
import 'package:pika_client_flutter/components/dummy_player.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketController {
  late WebSocketChannel channel;

  WebSocketController(String url, PikaDummyPlayer visitor, PikaBall ball) {
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

  void close() {
    channel.sink.close();
  }
}
