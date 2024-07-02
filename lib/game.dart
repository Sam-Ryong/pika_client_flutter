import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/collisions.dart';

class VolleyballGame extends FlameGame with TapDetector, HasCollisionDetection {
  late Player player1;
  late Player player2;
  late Ball ball;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    player1 = Player(Vector2(100, size.y - 50));
    player2 = Player(Vector2(size.x - 100, size.y - 50));
    ball = Ball(Vector2(size.x / 2, size.y / 2));

    add(player1);
    add(player2);
    add(ball);
  }

  @override
  void update(double dt) {
    super.update(dt);
    ball.position += ball.velocity * dt;

    // 경계 충돌 처리
    if (ball.position.x < 0 || ball.position.x > size.x - ball.size.x) {
      ball.velocity.x = -ball.velocity.x;
    }
    if (ball.position.y < 0 || ball.position.y > size.y - ball.size.y) {
      ball.velocity.y = -ball.velocity.y;
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    final tapPosition = info.eventPosition.global;
    if (tapPosition.x < size.x / 2) {
      player1.position = tapPosition - player1.size / 2;
    } else {
      player2.position = tapPosition - player2.size / 2;
    }
  }
}

class Player extends SpriteComponent
    with HasGameRef<VolleyballGame>, CollisionCallbacks {
  Player(Vector2 position) : super(position: position, size: Vector2(50, 50));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('player.bmp');
    add(RectangleHitbox());
  }
}

class Ball extends SpriteComponent
    with HasGameRef<VolleyballGame>, CollisionCallbacks {
  Vector2 velocity = Vector2(150, 150);

  Ball(Vector2 position) : super(position: position, size: Vector2(30, 30));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('ball.bmp');
    add(CircleHitbox());
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Player) {
      velocity.y = -velocity.y;
    }
  }
}
