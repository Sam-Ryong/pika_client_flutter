import 'dart:async';
import 'package:flame/components.dart';
import 'package:pika_client_flutter/hostgame.dart';

enum TextState {
  ready,
}

class Ready extends SpriteGroupComponent<TextState>
    with HasGameRef<VolleyballGame> {
  Ready();
  final int max_score = 15;
  late Map<TextState, Sprite> temp;
  int currentnum = 1;
  bool larging = false;
  Vector2 initPos = Vector2.all(0);

  @override
  FutureOr<void> onLoad() {
    temp = {};
    for (TextState state in TextState.values) {
      String spriteName = state.toString().split('.').last;
      temp[state] = Sprite(game.images.fromCache("Text/$spriteName.png"));
    }
    sprites = temp;
    current = TextState.ready;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (larging) {
      size.x = size.x + 1;
      size.y = size.y + 1;
      position.x = position.x - 0.5;
    }

    super.update(dt);
  }

  void makeLarge() {
    current = TextState.ready;
    larging = true;
  }

  void reset() {
    current = null;
    larging = false;
    size.x = 80;
    size.y = 24;
    position.x = initPos.x;
    position.y = initPos.y;
  }
}
