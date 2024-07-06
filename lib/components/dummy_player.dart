import 'dart:async';
import 'package:flame/components.dart';
import 'package:pika_client_flutter/hostgame.dart';
//import 'package:pika_client_flutter/visitorgame.dart';

enum PlayerState {
  idle,
  jump,
  spike,
  dash,
  win,
  lose,
}

class PikaDummyPlayer extends SpriteAnimationGroupComponent
    with HasGameRef<VolleyballGame> {
  PikaDummyPlayer({position}) : super(position: position);
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation spikeAnimation;
  late final SpriteAnimation dashAnimation;
  late final SpriteAnimation winAnimation;
  late final SpriteAnimation loseAnimation;

  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;
  @override
  FutureOr<void> onLoad() async {
    _loadAllAnimations();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;

    while (accumulatedTime >= fixedDeltaTime) {
      _updatePlayerState();
      accumulatedTime -= fixedDeltaTime;
    }

    super.update(dt);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation("idle", 9, 0.2);
    jumpAnimation = _spriteAnimation("jump", 8, 0.05);
    spikeAnimation = _spriteAnimation("spike", 8, 0.05);
    dashAnimation = _spriteAnimation("dash", 3, 0.2);
    winAnimation = _spriteAnimation("win", 5, 0.05);
    loseAnimation = _spriteAnimation("lose", 5, 0.05);

    // 모든 애니메이션들
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.spike: spikeAnimation,
      PlayerState.dash: dashAnimation,
      PlayerState.win: winAnimation,
      PlayerState.lose: loseAnimation,
    };

    // 현재 애니메이션
    current = PlayerState.idle;
    if (game.role == "host") flipHorizontallyAroundCenter();
  }

  SpriteAnimation _spriteAnimation(String state, int amount, double stepTime) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("player1/$state.png"),
      SpriteAnimationData.sequenced(
        amount: amount, //프레임 수
        stepTime: stepTime,
        textureSize: Vector2.all(64),
      ),
    );
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    current = playerState;
  }
}
