import 'dart:async';
import 'package:flame/components.dart';
import "package:flutter/services.dart";
import 'package:pika_client_flutter/hostgame.dart';

enum PlayerState {
  idle,
  jumping,
  spike,
}

enum PlayerDirection { left, right, none }

class PikaPlayer extends SpriteAnimationGroupComponent
    with HasGameRef<VolleyballGame>, KeyboardHandler {
  PikaPlayer({position}) : super(position: position);
  late final SpriteAnimation idleAnimation;
  final double stepTime = 0.2;
  PlayerDirection playerDirection = PlayerDirection.none;
  double moveSpeed = 100;
  Vector2 velocity = Vector2(0, 0);
  bool isFacingRight = true;

  @override
  FutureOr<void> onLoad() async {
    _loadAllAnimations();
    // 왼쪽, 중앙, 오른쪽, 위쪽 히트박스 추가

    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerMovement(dt);
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.arrowRight);
    if (isLeftKeyPressed && isRightKeyPressed) {
      playerDirection = PlayerDirection.none;
    } else if (isLeftKeyPressed) {
      playerDirection = PlayerDirection.left;
    } else if (isRightKeyPressed) {
      playerDirection = PlayerDirection.right;
    } else {
      playerDirection = PlayerDirection.none;
    }

    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation("idle", 8);

    // 모든 애니메이션들
    animations = {
      PlayerState.idle: idleAnimation,
    };

    // 현재 애니메이션
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("player1/$state.png"),
      SpriteAnimationData.sequenced(
        amount: amount, //프레임 수
        stepTime: stepTime,
        textureSize: Vector2.all(64),
      ),
    );
  }

  void _updatePlayerMovement(double dt) {
    double dx = 0.0;
    switch (playerDirection) {
      case PlayerDirection.left:
        if (isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = false;
        }
        dx -= moveSpeed;
        break;
      case PlayerDirection.right:
        if (!isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = true;
        }
        dx += moveSpeed;
        break;
      case PlayerDirection.none:
        break;
      default:
    }
    velocity = Vector2(dx, 0.0);
    position += velocity * dt;
  }
}
