import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import "package:flutter/services.dart";
import 'package:pika_client_flutter/components/ball.dart';
import 'package:pika_client_flutter/components/collision_block.dart';
import 'package:pika_client_flutter/components/player_hitbox.dart';
import 'package:pika_client_flutter/components/utils.dart';
import 'package:pika_client_flutter/hostgame.dart';
//import 'package:pika_client_flutter/visitorgame.dart';

enum PlayerState {
  idle,
  jump,
  spike,
  dash,
  win,
  lose,
}

class PikaPlayer extends SpriteAnimationGroupComponent
    with HasGameRef<VolleyballGame>, KeyboardHandler, CollisionCallbacks {
  PikaPlayer({position}) : super(position: position);
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation spikeAnimation;
  late final SpriteAnimation dashAnimation;
  late final SpriteAnimation winAnimation;
  late final SpriteAnimation loseAnimation;
  double horizontalMovement = 0;
  late String hostId = game.hostId;
  late String myId = game.myId;
  final double _gravity = 9.8;
  final double _jumpforce = 300;
  final double _terminalVelocity = 300;
  int isFacingRight = 1;
  bool isOnGround = true;
  bool startJump = false;
  bool isJumping = false;
  bool endJump = true;
  bool startDash = false;
  bool isDashing = false;
  bool endDash = true;
  bool isSpiking = false;
  bool left = false;
  bool right = false;
  bool up = false;
  bool down = false;
  bool ready = true;
  double moveSpeed = 100;
  bool isReset = false;
  bool needToFlip = false;
  bool win = false;
  bool lose = false;
  Vector2 velocity = Vector2(0, 0);
  Vector2 spawn = Vector2(0, 0);
  int countDt = 0;
  List<CollisionBlock> collisionBlocks = [];
  PlayerHitbox hitbox =
      PlayerHitbox(offsetX: 20, offsetY: 0, width: 44, height: 64);
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;
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
    accumulatedTime += dt;
    if (!win && !lose) {
      while (accumulatedTime >= fixedDeltaTime) {
        _updatePlayerState();
        _updatePlayerMovement(fixedDeltaTime);
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions();

        game.webSocketManager.sendPlayerInfo(hostId, myId, position, current);
        game.webSocketManager.sendPlayerDirection(hostId, myId, isFacingRight);
        accumulatedTime -= fixedDeltaTime;
      }
    } else {
      if (win) {
        current = PlayerState.win;
      } else if (lose) {
        current = PlayerState.lose;
      }
      game.webSocketManager.sendPlayerInfo(hostId, myId, position, current);
      game.webSocketManager.sendPlayerDirection(hostId, myId, isFacingRight);
    }

    super.update(dt);
  }

  void respawn() {
    scale.x = game.role == "host" ? 1 : -1;
    isFacingRight = game.role == "host" ? 1 : -1;
    position = spawn;
    if (game.role == "visitor") {
      position.x = position.x + 64;
    }
    game.webSocketManager.sendPlayerInfo(hostId, myId, position, current);
    game.webSocketManager.sendPlayerDirection(hostId, myId, isFacingRight);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    left = isLeftKeyPressed;
    final isRightKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.arrowRight);
    right = isRightKeyPressed;
    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;
    up = keysPressed.contains(LogicalKeyboardKey.arrowUp);
    down = keysPressed.contains(LogicalKeyboardKey.arrowDown);
    if (up) {
      isJumping = true;
      isDashing = false;
    } else if (keysPressed.contains(LogicalKeyboardKey.space)) {
      isJumping = false;
      isDashing = true;
    } else {
      isJumping = false;
      isDashing = false;
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is PikaBall) {
      other.collidedWithPlayer(intersectionPoints);
    }
    super.onCollision(intersectionPoints, other);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation("idle", 9, 0.2);
    jumpAnimation = _spriteAnimation("jump", 8, 0.05);
    spikeAnimation = _spriteAnimation("spike", 8, 0.05);
    dashAnimation = _spriteAnimation("dash", 3, 0.2);
    winAnimation = _spriteAnimation("win", 5, 0.3)..loop = false;
    loseAnimation = _spriteAnimation("lose", 5, 0.3)..loop = false;

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
    if (game.role == "visitor") {
      flipHorizontallyAroundCenter();
      isFacingRight = -1;
    }
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
      isFacingRight = -1;
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      isFacingRight = 1;
      flipHorizontallyAroundCenter();
    }
    if (endJump && isDashing) {
      playerState = PlayerState.dash;
    } else if (endDash && isJumping) {
      playerState = PlayerState.jump;
    } else if (!isOnGround) {
      if (endDash) {
        if (isSpiking) {
          playerState = PlayerState.spike;
        } else {
          playerState = PlayerState.jump;
        }
      } else if (!endDash && startDash) {
        playerState = PlayerState.dash;
      }
    } else if (isOnGround) {
      playerState = PlayerState.idle;
      endDash = true;
      startDash = false;
      endJump = true;
      startJump = false;
    }

    //if (!isDashed && !isOnGround) playerState = PlayerState.dash;

    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if (isDashing && isOnGround) {
      _playerDash(dt);
    } else {
      if (isJumping && isOnGround) {
        _playerJump(dt);
      }
      if (endDash) {
        velocity.x = horizontalMovement * moveSpeed;
        position.x += velocity.x * dt;
      } else {
        velocity.x = isFacingRight * moveSpeed;
        position.x += velocity.x * dt;
      }
    }
  }

  void _playerDash(double dt) {
    if (game.playSounds) {
      FlameAudio.play("jump.wav", volume: game.soundVolume);
      game.webSocketManager.sendSound(game, "jump");
    }
    velocity.y = -_jumpforce * 0.5;
    position.y += velocity.y * dt;
    //isJumping = true;
    isOnGround = false;
    startDash = true;
    endDash = false;
  }

  void _playerJump(double dt) {
    if (game.playSounds) {
      FlameAudio.play("jump.wav", volume: game.soundVolume);
      game.webSocketManager.sendSound(game, "jump");
    }
    velocity.y = -_jumpforce;
    position.y += velocity.y * dt;
    //isJumping = true;
    isOnGround = false;
    startJump = true;
    endJump = false;
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
