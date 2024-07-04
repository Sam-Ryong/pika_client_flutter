import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/collisions.dart';
import 'package:pika_client_flutter/controller/web_socket_controller.dart';

class VolleyballGame extends FlameGame
    with PanDetector, TapDetector, HasCollisionDetection {
  late Player player1;
  late Player player2;
  late Ball ball;
  late WebSocketController webSocketManager;
  int gravity = 500;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    player1 = Player(Vector2(100, size.y - 50));
    player2 = Player(Vector2(size.x - 100, size.y - 50));
    ball = Ball(Vector2(size.x / 2, size.y / 2));

    add(player1);
    add(player2);
    add(ball);
    webSocketManager = WebSocketController('ws://10.0.2.2:3000');
  }

  @override
  void update(double dt) {
    super.update(dt);
    ball.position += ball.velocity * dt;
    ball.velocity.y += gravity * dt;

    // 경계 충돌 처리
    if (ball.position.x < 0 || ball.position.x > size.x - ball.size.x) {
      ball.velocity.x = -ball.velocity.x;
    }
    if (ball.position.y < 0 || ball.position.y > size.y - ball.size.y) {
      ball.velocity.y = -ball.velocity.y;
    }

    // 플레이어가 공중에 있을 때 처리
    if (player1.position.y < size.y - player1.size.y) {
      player1.position.y = player1.position.y + 0.5 + gravity * dt * dt;
    }
    sendPositions();
  }

  void sendPositions() {
    final player1Pos = 'Player1: ${player1.position}';
    final player2Pos = 'Player2: ${player2.position}';
    final ballPos = 'Ball: ${ball.position}';

    webSocketManager.sendMessage(player1Pos);
    webSocketManager.sendMessage(player2Pos);
    webSocketManager.sendMessage(ballPos);
  }

  @override
  void onRemove() {
    // 게임이 종료될 때 웹 소켓 연결을 닫음
    webSocketManager.close();
    super.onRemove();
  }

  void movePlayer1Left() {
    if (player1.position.x > 0) {
      player1.position.x -= 10;
    }
  }

  void movePlayer1Right() {
    if (player1.position.x < size.x - player1.size.x) {
      player1.position.x += 10;
    }
  }

  void movePlayer1Up() {
    if (player1.position.y > 0) {
      player1.position.y -= 10;
    }
  }

  void movePlayer1Down() {
    if (player1.position.y < size.y - player1.size.y) {
      player1.position.y += 10;
    }
  }
}

class Player extends SpriteComponent
    with HasGameRef<VolleyballGame>, CollisionCallbacks {
  Player(Vector2 position) : super(position: position, size: Vector2(50, 50));
  Vector2 velocity = Vector2(0, 0);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('player.bmp');

    // 왼쪽, 중앙, 오른쪽, 위쪽 히트박스 추가
    add(RectangleHitbox(position: Vector2(0, 0), size: Vector2(16, 50))
      ..collisionType = CollisionType.active); // 왼쪽
    add(RectangleHitbox(position: Vector2(17, 0), size: Vector2(16, 50))
      ..collisionType = CollisionType.active); // 중앙
    add(RectangleHitbox(position: Vector2(34, 0), size: Vector2(16, 50))
      ..collisionType = CollisionType.active); // 오른쪽
    add(RectangleHitbox(position: Vector2(0, 0), size: Vector2(50, 10))
      ..collisionType = CollisionType.active); // 위쪽
  }
}

class Ball extends SpriteComponent
    with HasGameRef<VolleyballGame>, CollisionCallbacks {
  Vector2 velocity = Vector2(0, 0); // 초기 속도 (y축 속도는 0으로 시작)

  Ball(Vector2 position) : super(position: position, size: Vector2(30, 30));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('ball.bmp');
    add(CircleHitbox());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    double loss = 0.8;
    super.onCollision(intersectionPoints, other);
    if (other is Player) {
      final intersection = intersectionPoints.first;
      if (intersection.y < other.position.y + 10) {
        // 위쪽 히트박스에 충돌
        velocity.y = velocity.y * loss;
        velocity.y = -velocity.y.abs(); // 위쪽으로 반사
      } else if (intersection.x < other.position.x + 16) {
        // 왼쪽 히트박스에 충돌
        velocity.x = -velocity.x.abs(); // 왼쪽으로 반사
      } else if (intersection.x > other.position.x + 34) {
        // 오른쪽 히트박스에 충돌
        velocity.x = velocity.x.abs(); // 오른쪽으로 반사
      } else {
        // 중앙 히트박스에 충돌
        velocity.y = -velocity.y; // y축 방향 반사
      }
    }
  }
}
