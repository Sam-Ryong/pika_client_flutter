import "dart:async";
import "dart:math";

import "package:flame/components.dart";
import "package:flame_tiled/flame_tiled.dart";
import "package:pika_client_flutter/components/background_tile.dart";
import "package:pika_client_flutter/components/ball.dart";
import "package:pika_client_flutter/components/ball_clone.dart";
import "package:pika_client_flutter/components/collision_block.dart";
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

  PikaMap({
    required this.player,
    required this.player2,
    required this.ball,
    required this.spike,
    required this.shadow1,
    required this.shadow2,
    required this.role,
  });

  @override
  FutureOr<void> onLoad() async {
    map = await TiledComponent.load(
      "map2.tmx",
      Vector2(8, 8),
    );
    add(map);

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
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          case "OtherPlayer":
            player2.position = Vector2(spawnPoint.x, spawnPoint.y);
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
