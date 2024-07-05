import "dart:async";

import "package:flame/components.dart";
import "package:flame_tiled/flame_tiled.dart";
import "package:pika_client_flutter/objects/player.dart";

class PikaMap extends World {
  late TiledComponent map;

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

    for (final spawnPoint in spawnPointLayer!.objects) {
      switch (spawnPoint.class_) {
        case "PikaPlayer":
          player.position = Vector2(spawnPoint.x, spawnPoint.y);
          add(player);
          break;
        default:
      }
    }
    return super.onLoad();
  }
}
