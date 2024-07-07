import 'dart:async';
import 'package:flame/components.dart';
import 'package:pika_client_flutter/hostgame.dart';

enum NumState {
  n1,
  n2,
  n3,
  n4,
  n5,
  n6,
  n7,
  n8,
  n9,
  n10,
  n11,
  n12,
  n13,
  n14,
  n15,
}

class Score extends SpriteGroupComponent<NumState>
    with HasGameRef<VolleyballGame> {
  Score();
  final int max_score = 15;
  late Map<NumState, Sprite> temp;
  int currentnum = 1;

  @override
  FutureOr<void> onLoad() {
    temp = {};
    for (NumState state in NumState.values) {
      String spriteName = state.toString().split('.').last.substring(1);
      temp[state] = Sprite(game.images.fromCache("Number/$spriteName.png"));
    }
    sprites = temp;
    current = NumState.n1;

    return super.onLoad();
  }

  void increase() {
    if (currentnum < max_score) {
      currentnum++;
      current = NumState.values
          .firstWhere((e) => e.toString().split('.').last == "n$currentnum");
    }
    game.slow = 0.3;

    Future.delayed(const Duration(seconds: 1), () {
      game.host.respawn();
      game.ball.respawn();
      game.slow = 0;
      game.darkOverlay.reset();
      game.ready1.makeLarge();
      Future.delayed(const Duration(milliseconds: 1500), () {
        game.ready1.reset();
        game.host.respawn();
        game.ball.respawn();
        game.slow = 1;
      });
    });
  }

  void reset() {
    if (current == NumState.n15) {
      current = NumState.n1;
      currentnum = 1;
    }
  }
}
