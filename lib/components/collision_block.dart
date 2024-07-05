import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  bool isNet;
  bool isAir;
  CollisionBlock({
    position,
    size,
    this.isNet = false,
    this.isAir = false,
  }) : super(
          position: position,
          size: size,
        ) {
    //debugMode = true;
  }
}
