import "dart:async";

import "package:flame/components.dart";
import "package:flame_tiled/flame_tiled.dart";

class PikaMap extends World {
  late TiledComponent map;

  @override
  FutureOr<void> onLoad() async {
    map = await TiledComponent.load(
      "map2.tmx",
      Vector2(8, 8),
    );
    add(map);
    return super.onLoad();
  }
}
