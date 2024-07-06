import "dart:async";
import "dart:math";

import "package:flame/components.dart";
import "package:flame_tiled/flame_tiled.dart";
import "package:pika_client_flutter/components/background_tile.dart";
import "package:pika_client_flutter/components/ball.dart";
import "package:pika_client_flutter/components/ball_clone.dart";
import "package:pika_client_flutter/components/collision_block.dart";
import "package:pika_client_flutter/components/score.dart";
//import "package:pika_client_flutter/components/player.dart";

class PikaMap extends World {
  var random = Random();

  late TiledComponent map;
  List<CollisionBlock> collisionBlocks = [];

  final dynamic player;
  final dynamic player2;
  final PikaBall ball;
  final PikaBallClone spike;
  final PikaBallClone shadow1;
  final PikaBallClone shadow2;

  final String role;
  final Score hostScore;
  final Score visitorScore;
  late Vector2 player1Spawn;
  late Vector2 player2Spawn;

  PikaMap({
    required this.player,
    required this.player2,
    required this.ball,
    required this.spike,
    required this.shadow1,
    required this.shadow2,
    required this.role,
    required this.hostScore,
    required this.visitorScore,
  });

  @override
  FutureOr<void> onLoad() async {
    map = await TiledComponent.load(
      "map2.tmx",
      Vector2(8, 8),
    );
    add(map);
    add(hostScore);
    add(visitorScore);
    _spawningObjects();
    scrollingBackground();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (random.nextInt(100) < 1) {
      scrollingBackground();
    }

    super.update(dt);
  }

  void scrollingBackground() {
    double randomDouble = random.nextDouble() * 150;
    final backgroundLayer = map.tileMap.getLayer("Background");
    if (backgroundLayer != null) {
      final backgroundTile = BackgroundTile(
        Vector2(0, randomDouble),
        random.nextDouble(),
      );

      add(backgroundTile);
    }
  }

  void _spawningObjects() {
    final spawnPointLayer = map.tileMap.getLayer<ObjectGroup>("Player1");
    if (spawnPointLayer != null) {
      for (final spawnPoint in spawnPointLayer.objects) {
        switch (spawnPoint.class_) {
          case "PikaPlayer":
            player1Spawn = Vector2(spawnPoint.x, spawnPoint.y);
            player.position = player1Spawn;
            player.spawn = player1Spawn;
            add(player);
            break;
          case "OtherPlayer":
            player2Spawn = Vector2(spawnPoint.x, spawnPoint.y);
            player2.position = player2Spawn;
            player2.spawn = player2Spawn;
            add(player2);
            break;
          default:
        }
      }
    }

    final collisionLayer = map.tileMap.getLayer<ObjectGroup>("Collisions");

    if (collisionLayer != null) {
      for (final collision in collisionLayer.objects) {
        switch (collision.class_) {
          case "Net":
            final net = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isNet: true,
            );
            collisionBlocks.add(net);
            add(net);
            break;
          case "Air":
            final air = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isAir: true,
            );
            collisionBlocks.add(air);
            add(air);
            break;
          case "HostGround":
            final hostGround = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isHost: true,
            );
            collisionBlocks.add(hostGround);
            add(hostGround);
            break;
          case "VisitorGround":
            final visitorGround = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isVisit: true,
            );
            collisionBlocks.add(visitorGround);
            add(visitorGround);
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isNet: false,
            );
            collisionBlocks.add(block);
            add(block);
        }
      }
    }
    final ballLayer = map.tileMap.getLayer<ObjectGroup>("Ball");

    if (ballLayer != null) {
      for (final ballPoint in ballLayer.objects) {
        switch (ballPoint.class_) {
          case "Ball":
            ball.position = Vector2(ballPoint.x, ballPoint.y);
            ball.hostSpawn = Vector2(ballPoint.x, ballPoint.y);
            shadow1.position = Vector2(ballPoint.x, ballPoint.y);
            shadow2.position = Vector2(ballPoint.x, ballPoint.y);
            add(shadow2);
            add(shadow1);
            add(ball);
            add(spike);
            break;
          case "VBall":
            ball.visitSpawn = Vector2(ballPoint.x, ballPoint.y);
            shadow1.position = Vector2(ballPoint.x, ballPoint.y);
            shadow2.position = Vector2(ballPoint.x, ballPoint.y);
            add(shadow2);
            add(shadow1);
            add(ball);
            add(spike);
            break;
          default:
        }
      }
    }

    ball.collisionBlocks = collisionBlocks;
    if (role == "host") {
      player.collisionBlocks = collisionBlocks;
    } else {
      player2.collisionBlocks = collisionBlocks;
    }
  }
}
