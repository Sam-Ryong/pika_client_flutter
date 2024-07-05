import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pika_client_flutter/hostgame.dart';

class SpikeButton extends SpriteComponent
    with HasGameRef<VolleyballGame>, TapCallbacks {
  SpikeButton();

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache("HUD/SpikeButton.png"));
    position = Vector2(75, 280);
    priority = 10;
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.host.isSpiking = true;
    game.host.isDashing = true;
    game.host.isJumping = false;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.host.isSpiking = false;
    game.host.isDashing = false;
    game.host.isJumping = true;
    super.onTapUp(event);
  }
}
