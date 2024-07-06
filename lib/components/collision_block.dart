import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  bool isNet;
  bool isAir;
  bool isHost;
  bool isVisit;
  CollisionBlock({
    position,
    size,
    this.isNet = false,
    this.isAir = false,
    this.isHost = false,
    this.isVisit = false,
  }) : super(
          position: position,
          size: size,
        ) {
    //debugMode = true;
  }
}
