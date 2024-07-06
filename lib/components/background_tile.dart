import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:pika_client_flutter/hostgame.dart';

class BackgroundTile extends SpriteComponent with HasGameRef<VolleyballGame> {
  var random = Random();
  final double scrollSpeed;
  int count = 0;

  BackgroundTile(
    position,
    this.scrollSpeed,
  ) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    size = Vector2(48, 24);
    sprite = Sprite(game.images.fromCache("Background/Cloud.png"));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (count == 8) {
      double randomDouble = random.nextDouble() * 12;
      size.x = 48 - randomDouble;
      size.y = 24 - randomDouble * 0.5;
      position.x += randomDouble * 0.5;
      position.x -= randomDouble * 0.25;
      count = 0;
    }
    position.x += scrollSpeed;
    count++;
    super.update(dt);
  }
}
