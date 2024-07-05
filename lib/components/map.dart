import "dart:async";

import "package:flame/components.dart";
import "package:flame_tiled/flame_tiled.dart";
import "package:pika_client_flutter/components/collision_block.dart";
import "package:pika_client_flutter/components/player.dart";

class PikaMap extends World {
  late TiledComponent map;
  List<CollisionBlock> collisionBlocks = [];

  final PikaPlayer player;

  PikaMap({required this.player});

  @override
  FutureOr<void> onLoad() async {
    map = await TiledComponent.load(
      "map2.tmx",
      Vector2(8, 8),
    );
    add(map);
    final spawnPointLayer = map.tileMap.getLayer<ObjectGroup>("Player1");

    if (spawnPointLayer != null) {
      for (final spawnPoint in spawnPointLayer.objects) {
        switch (spawnPoint.class_) {
          case "PikaPlayer":
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
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
    player.collisionBlocks = collisionBlocks;
    return super.onLoad();
  }
}
