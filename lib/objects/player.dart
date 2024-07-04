import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pika_client_flutter/hostgame.dart';

enum PlayerState {
  idle,
  jumping,
  spike,
}

class PikaPlayer extends SpriteAnimationGroupComponent
    with HasGameRef<VolleyballGame> {
  PikaPlayer({position}) : super(position: position);

  late final SpriteAnimation idleAnimation;
  final double stepTime = 0.2;

  @override
  FutureOr<void> onLoad() async {
    _loadAllAnimations();
    // 왼쪽, 중앙, 오른쪽, 위쪽 히트박스 추가

    return super.onLoad();
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation("idle", 8);

    // 모든 애니메이션들
    animations = {
      PlayerState.idle: idleAnimation,
    };

    // 현재 애니메이션
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("player1/$state.png"),
      SpriteAnimationData.sequenced(
        amount: amount, //프레임 수
        stepTime: stepTime,
        textureSize: Vector2.all(64),
      ),
    );
  }
}
