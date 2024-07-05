import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  bool isNet;
  CollisionBlock({position, size, this.isNet = false})
      : super(
          position: position,
          size: size,
        ) {
    //debugMode = true;
  }
}
