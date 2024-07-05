import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  bool isNet;
  bool isPlayer;
  CollisionBlock({
    position,
    size,
    this.isNet = false,
    this.isPlayer = false,
  }) : super(
          position: position,
          size: size,
        ) {
    //debugMode = true;
  }
}
