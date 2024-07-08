import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:pika_client_flutter/components/ball_clone.dart';
import 'package:pika_client_flutter/components/collision_block.dart';
import 'package:pika_client_flutter/components/dummy_player.dart';
import 'package:pika_client_flutter/components/player.dart';
import 'package:pika_client_flutter/components/player_hitbox.dart';
import 'package:pika_client_flutter/components/score.dart';
import 'package:pika_client_flutter/components/utils.dart';
import 'package:pika_client_flutter/hostgame.dart';
//import 'package:pika_client_flutter/visitorgame.dart';

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
  final double _jumpforce = 800;
  final double _terminalVelocity = 800;
  late PikaPlayer player;
  late PikaDummyPlayer visitor;
  bool isOnGround = false;
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
  late Score hostScore = game.hostScore;
  late Score visitorScore = game.visitorScore;
  Vector2 hostSpawn = Vector2(0, 0);
  Vector2 visitSpawn = Vector2(0, 0);
  int dtCount = 0;
  bool isScoring = false;
  late String hostId = game.hostId;
  late String myId = game.myId;

  bool where = true;
  bool ready = true;

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
    visitor = game.visitor;
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
    if (game.role == "host") {
      game.webSocketManager.sendBallInfo(hostId, myId, position, velocity);
    }

    super.update(dt);
  }

  void respawn() {
    if (where) {
      position = hostSpawn;
    } else {
      position = visitSpawn;
    }
    isScoring = false;
    velocity = Vector2(0, 0);
  }

  void setRemoteInfo(String pos, String vel) {
    List<dynamic> p = jsonDecode(pos);
    List<dynamic> v = jsonDecode(vel);
    position.x = p[0];
    position.y = p[1];
    velocity.x = v[0];
    velocity.y = v[1];
  }

  void setRemoteState(String state) {
    if (state == "s") {
      isSpiked = true;
      spike.visible();
      shadow1.visible();
      shadow2.visible();
    } else if (state == "n") {
      spike.invisible();
      shadow1.invisible();
      shadow2.invisible();
      isSpiked = false;
    }
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
      velocity.x = ax * sqrt(ax * ax);
      velocity.y = -velocity.y / velocity.y * 400;
      game.webSocketManager.sendBallState(hostId, myId, "n");
    } else {
      isSpiked = true;
      current = BallState.normal;
      spike.visible();
      shadow1.visible();
      shadow2.visible();
      game.webSocketManager.sendBallState(hostId, myId, "s");
      if (player.up) {
        if (player.left) {
          velocity.x = -600;
        } else if (player.right) {
          velocity.x = 600;
        } else {
          velocity.x = ax;
        }
        velocity.y = -velocity.y / velocity.y * 600;
      } else if (player.down) {
        velocity.x = ax;
        velocity.y = 600;
      } else {
        if (player.left) {
          velocity.x = -600;
          velocity.y = 0;
        } else if (player.right) {
          velocity.x = 600;
          velocity.y = 0;
        }
      }
      if (!player.left && !player.right && !player.up && !player.down) {
        velocity.x = 300;
        velocity.y = 0;
      }
    }
    if (game.role == "visitor") {
      game.webSocketManager.sendBallInfo(hostId, myId, position, velocity);
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
      if (!isScoring && game.role == "host") {
        if (block.isHost) {
          if (checkCollision(this, block)) {
            visitorScore.increase();
            game.webSocketManager.sendPoint(hostId, myId, "visitor");
            where = false;
            isScoring = true;
          }
        } else if (block.isVisit) {
          if (checkCollision(this, block)) {
            hostScore.increase();
            game.webSocketManager.sendPoint(hostId, myId, "host");
            where = true;
            isScoring = true;
          }
        }
      }

      if (!block.isAir) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = -velocity.x;
            position.x = block.x - hitbox.offsetX - hitbox.width - 1;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = -velocity.x;
            position.x = block.x + block.width + 1;
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
      if (!isScoring && game.role == "host") {
        if (block.isHost) {
          if (checkCollision(this, block)) {
            visitorScore.increase();
            game.webSocketManager.sendPoint(hostId, myId, "visitor");
            where = false;
            isScoring = true;
          }
        } else if (block.isVisit) {
          if (checkCollision(this, block)) {
            hostScore.increase();
            game.webSocketManager.sendPoint(hostId, myId, "host");
            where = true;
            isScoring = true;
          }
        }
      }

      if (!block.isAir) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            //velocity.y = -velocity.y / velocity.y * 600;
            velocity.y = -velocity.y;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnGround = true;

            break;
          }
          if (velocity.y < 0) {
            velocity.y = -velocity.y;
            //velocity.y = velocity.y / velocity.y * 600;
            position.y = block.y + block.height;

            break;
          }
        }
      }
    }
  }
}
