import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pika_client_flutter/components/collision_block.dart';
import 'package:pika_client_flutter/components/player.dart';
import 'package:pika_client_flutter/components/player_hitbox.dart';
import 'package:pika_client_flutter/components/utils.dart';
import 'package:pika_client_flutter/hostgame.dart';

enum BallState {
  normal,
  spike,
}

class PikaBall extends SpriteAnimationGroupComponent
    with HasGameRef<VolleyballGame>, KeyboardHandler, CollisionCallbacks {
  PikaBall({position}) : super(position: position);
  late final SpriteAnimation normalAnimation;
  late final SpriteAnimation spikeAnimation;

  final double _gravity = 9.8;
  final double _jumpforce = 1000;
  final double _terminalVelocity = 1000;

  bool isOnGround = true;
  bool isJumped = false;
  double moveSpeed = 100;
  Vector2 velocity = Vector2(0, 0);
  List<CollisionBlock> collisionBlocks = [];
  BallHitbox hitbox = BallHitbox(offsetX: 0, offsetY: 0, width: 40, height: 40);
  @override
  FutureOr<void> onLoad() async {
    _loadAllAnimations();
    debugMode = true;
    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updateBallState();
    _checkHorizontalCollisions();
    _applyGravity(dt);
    _checkVerticalCollisions();
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is PikaPlayer) {
      print(intersectionPoints);
      velocity.y = -velocity.y;
    }
    super.onCollision(intersectionPoints, other);
  }

  void _loadAllAnimations() {
    normalAnimation = _spriteAnimation("normal", 5, 0.1);
    spikeAnimation = _spriteAnimation("spike", 3, 0.1);

    // 모든 애니메이션들
    animations = {
      BallState.normal: normalAnimation,
      BallState.spike: spikeAnimation,
    };

    // 현재 애니메이션
    current = BallState.normal;
  }

  SpriteAnimation _spriteAnimation(String state, int amount, double stepTime) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("ball/$state.png"),
      SpriteAnimationData.sequenced(
        amount: amount, //프레임 수
        stepTime: stepTime,
        textureSize: Vector2.all(40),
      ),
    );
  }

  void _updateBallState() {
    // 미완성
    BallState ballState = BallState.normal;

    //if (false) ballState = BallState.spike;

    current = ballState;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isNet) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = -velocity.x;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = -velocity.x;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      } else if (block.isNet) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = -velocity.x;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = -velocity.x;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpforce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isNet) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = -velocity.y;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = -velocity.y;
            position.y = block.y + block.height;
            break;
          }
        }
      } else if (block.isNet) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = -velocity.y;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = -velocity.y;
            position.y = block.y + block.height - hitbox.offsetY;
            break;
          }
        }
      }
    }
  }
}
