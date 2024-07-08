import 'dart:convert';
import 'package:pika_client_flutter/main.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LightWebSocketController {
  late WebSocketChannel channel;

  LightWebSocketController(String url, GameRoomList gameRooms) {
    channel = WebSocketChannel.connect(Uri.parse(url));
    channel.stream.listen(
      (message) {
        Map<String, dynamic> data = jsonDecode(message);
        String type = data["type"];
        if (type == "getRoom") {
          gameRooms.setGameRooms(data["roomList"]);
        }
      },
      onError: (error) {},
      onDone: () {},
    );
  }

  void getRooms(String myId) {
    Map<String, dynamic> data = {
      'type': "getRoom",
      'host': myId,
    };
    channel.sink.add(jsonEncode(data));
  }
}
