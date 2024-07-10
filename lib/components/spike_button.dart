import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pika_client_flutter/hostgame.dart';

class SpikeButton extends SpriteComponent
    with HasGameRef<VolleyballGame>, TapCallbacks {
  SpikeButton();

  @override
  FutureOr<void> onLoad() {
    scale = Vector2(2, 2);
    sprite = Sprite(game.images.fromCache("HUD/SpikeButton.png"));
    position = Vector2(game.size.x / 2 * 0.05, game.size.y * 0.5);
    priority = 10;
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!game.host.isOnGround) {
      if (game.playSounds) {
        FlameAudio.play("spike.wav", volume: game.soundVolume);
        game.webSocketManager.sendSound(game, "spike");
      }
      game.host.isSpiking = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        game.host.isSpiking = false;
      });
    } else {
      game.host.isDashing = true;
      game.host.isJumping = false;
    }

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
