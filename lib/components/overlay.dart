import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

class DarkOverlayComponent extends Component with HasGameRef {
  double _alpha = 0;
  late final Paint _paint = Paint()
    ..color = Color.fromRGBO(0, 0, 0, _alpha)
    ..blendMode = BlendMode.srcOver;

  DarkOverlayComponent();

  @override
  void render(Canvas canvas) {
    final size = gameRef.size;
    _paint.color = Color.fromRGBO(0, 0, 0, _alpha);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _paint);
  }

  void darken(double amount) {
    _alpha += amount;
    if (_alpha > 1.0) {
      _alpha = 1.0; // 알파 값이 1.0을 넘지 않도록 제한
    }
  }

  void reset() {
    _alpha = 0; // 초기화
  }
}
