import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketController {
  late WebSocketChannel channel;

  WebSocketController(String url) {
    channel = WebSocketChannel.connect(Uri.parse(url));
    channel.stream.listen(
      (message) {
        print('Received: $message');
        // 여기에서 메시지를 처리할 수 있습니다.
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket closed');
      },
    );
  }

  void sendMessage(String message) {
    print('Sending message: $message');
    channel.sink.add(message);
  }

  void close() {
    channel.sink.close();
  }
}
