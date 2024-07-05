import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import "package:flutter/services.dart";
import 'package:pika_client_flutter/components/collision_block.dart';
import 'package:pika_client_flutter/components/player_hitbox.dart';
import 'package:pika_client_flutter/components/utils.dart';
import 'package:pika_client_flutter/hostgame.dart';

enum PlayerState {
  idle,
  jump,
  spike,
  dash,
  win,
  lose,
}

class PikaPlayer extends SpriteAnimationGroupComponent
    with HasGameRef<VolleyballGame>, KeyboardHandler {
  PikaPlayer({position}) : super(position: position);
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation spikeAnimation;
  late final SpriteAnimation dashAnimation;
  late final SpriteAnimation winAnimation;
  late final SpriteAnimation loseAnimation;
  double horizontalMovement = 0;

  final double _gravity = 9.8;
  final double _jumpforce = 300;
  final double _terminalVelocity = 300;

  bool isOnGround = true;
  bool isJumped = false;
  double moveSpeed = 100;
  Vector2 velocity = Vector2(0, 0);
  List<CollisionBlock> collisionBlocks = [];
  PlayerHitbox hitbox =
      PlayerHitbox(offsetX: 4, offsetY: 0, width: 56, height: 64);

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

    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovement(dt);
    _checkHorizontalCollisions();
    _applyGravity(dt);
    _checkVerticalCollisions();
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.arrowRight);
    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;
    isJumped = keysPressed.contains(LogicalKeyboardKey.arrowUp);
    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation("idle", 9, 0.2);
    jumpAnimation = _spriteAnimation("jump", 8, 0.05);
    spikeAnimation = _spriteAnimation("spike", 8, 0.05);
    dashAnimation = _spriteAnimation("dash", 3, 0.05);
    winAnimation = _spriteAnimation("win", 5, 0.05);
    loseAnimation = _spriteAnimation("lose", 5, 0.05);

    // 모든 애니메이션들
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.spike: spikeAnimation,
      PlayerState.dash: dashAnimation,
      PlayerState.win: winAnimation,
      PlayerState.lose: loseAnimation,
    };

    // 현재 애니메이션
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount, double stepTime) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("player1/$state.png"),
      SpriteAnimationData.sequenced(
        amount: amount, //프레임 수
        stepTime: stepTime,
        textureSize: Vector2.all(64),
      ),
    );
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }
    if (!isOnGround) playerState = PlayerState.jump;

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if (isJumped && isOnGround) {
      _playerJump(dt);
    }
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _playerJump(double dt) {
    velocity.y = -_jumpforce;
    position.y += velocity.y * dt;
    isJumped = false;
    isOnGround = false;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isNet) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      } else if (block.isNet) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
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
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height;
            break;
          }
        }
      } else if (block.isNet) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offsetY;
            break;
          }
        }
      }
    }
  }
}
