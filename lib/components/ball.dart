import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pika_client_flutter/components/ball_clone.dart';
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
  late PikaPlayer player;
  bool isOnGround = true;
  bool isJumped = false;
  bool isSpiked = false;
  double moveSpeed = 100;
  Vector2 velocity = Vector2(0, 0);
  List<CollisionBlock> collisionBlocks = [];
  BallHitbox hitbox = BallHitbox(offsetX: 0, offsetY: 0, width: 40, height: 40);
  final List<Vector2> previousPositions = [];
  final int maxTrailLength = 2; // 잔상의 개수
  late PikaBallClone spike = game.spike;
  late PikaBallClone shadow1 = game.shadow1;
  late PikaBallClone shadow2 = game.shadow2;
  int dtCount = 0;

  @override
  FutureOr<void> onLoad() async {
    _loadAllAnimations();
    //debugMode = true;
    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
      ),
    );
    previousPositions.add(position);
    previousPositions.add(position);

    player = game.host;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    //_updateBallState();
    _checkHorizontalCollisions();
    _applyGravity(dt);
    _checkVerticalCollisions();
    if (dtCount == 5) {
      previousPositions.add(position.clone());
      if (previousPositions.length > maxTrailLength) {
        previousPositions.removeAt(0);
      }
      dtCount = 0;
    }

    position.x += velocity.x * dt;
    shadow1.position = previousPositions[1];
    shadow2.position = previousPositions[0];
    spike.position = position;
    dtCount++;
    super.update(dt);
  }

  void collidedWithPlayer(Set<Vector2> intersectionPoints) {
    double centerpoint = intersectionPoints.length == 2
        ? (intersectionPoints.toList()[0][0] +
                intersectionPoints.toList()[1][0]) /
            2
        : position.x;
    double ax = position.x + 20 - centerpoint;
    if (!player.isSpiking) {
      spike.invisible();
      shadow1.invisible();
      shadow2.invisible();
      isSpiked = false;
      current = BallState.normal;
      velocity.x = ax * 10;
      velocity.y = -velocity.y / velocity.y * 400;
    } else {
      isSpiked = true;
      current = BallState.normal;
      spike.visible();
      shadow1.visible();
      shadow2.visible();
      if (player.up) {
        if (player.left) {
          velocity.x = -500;
        } else if (player.right) {
          velocity.x = 500;
        } else {
          velocity.x = ax;
        }
        velocity.y = -velocity.y / velocity.y * 500;
      } else if (player.down) {
        velocity.x = ax;
        velocity.y = 500;
      } else {
        if (player.left) {
          velocity.x = -500;
          velocity.y = 0;
        } else if (player.right) {
          velocity.x = 500;
          velocity.y = 0;
        }
      }
      if (!player.left && !player.right && !player.up && !player.down) {
        velocity.x = 300;
        velocity.y = 0;
      }
    }
  }

  void _loadAllAnimations() {
    normalAnimation = _spriteAnimation("normal", 5, 0.1);
    spikeAnimation = _spriteAnimation("spike", 1, 1);

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

  /*
  void _updateBallState() {
    // 미완성
    BallState ballState = BallState.normal;

    current = ballState;
  }
  */
  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isAir) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = -velocity.x;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = -velocity.x;
            position.x = block.x + block.width;
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
      if (!block.isAir) {
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
      }
    }
  }
}
