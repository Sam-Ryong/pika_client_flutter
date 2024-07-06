import 'dart:async';
import 'package:flame/components.dart';
import 'package:pika_client_flutter/hostgame.dart';
//import 'package:pika_client_flutter/visitorgame.dart';

enum ShadowState {
  spike,
  shadow1,
  shadow2,
}

class PikaBallClone extends SpriteAnimationGroupComponent
    with HasGameRef<VolleyballGame> {
  final String name;
  PikaBallClone(this.name, {position}) : super(position: position);
  late final SpriteAnimation spikeAnimation;
  late final SpriteAnimation shadow1Animation;
  late final SpriteAnimation shadow2Animation;

  @override
  FutureOr<void> onLoad() async {
    _loadAllAnimations();
    //debugMode = true;

    return super.onLoad();
  }

  void _loadAllAnimations() {
    spikeAnimation = _spriteAnimation("spike", 2, 0.1)..loop = false;
    shadow1Animation = _spriteAnimation("shadow1", 1, 1);
    shadow2Animation = _spriteAnimation("shadow2", 1, 1);

    // 모든 애니메이션들
    animations = {
      ShadowState.spike: spikeAnimation,
      ShadowState.shadow1: shadow1Animation,
      ShadowState.shadow2: shadow2Animation,
    };

    // 현재 애니메이션
  }

  void invisible() {
    current = null;
  }

  void visible() {
    current = null;
    if (name == "shadow1") {
      current = ShadowState.shadow1;
    } else if (name == "shadow2") {
      current = ShadowState.shadow2;
    } else if (name == "spike") {
      current = ShadowState.spike;
    }
  }

  SpriteAnimation _spriteAnimation(String state, int amount, double stepTime) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("ball/$state.png"),
      SpriteAnimationData.sequenced(
        amount: amount, //프레임 수
        stepTime: stepTime,
        textureSize: Vector2.all(40),
      ),
    );
  }
}
