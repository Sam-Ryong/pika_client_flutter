import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pika_client_flutter/controller/web_socket_controller.dart';
import 'package:pika_client_flutter/map/map.dart';
import 'package:pika_client_flutter/objects/player.dart';

class VolleyballGame extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks {
  late WebSocketController webSocketManager;
  PikaPlayer host = PikaPlayer();
  late final CameraComponent cam;
  late JoystickComponent joystick;
  bool showJoystick = true;

  int gravity = 500;

  @override
  Color backgroundColor() => const Color(0xFFeeeeee);

  @override
  Future<void> onLoad() async {
    await images.loadAllImages();
    final world = PikaMap(player: host);
    cam = CameraComponent.withFixedResolution(
      world: world,
      width: 432,
      height: 304,
    );
    cam.viewfinder.anchor = Anchor.topLeft;

    add(cam);
    add(world);

    if (showJoystick) {
      addJoystick();
    }

    webSocketManager = WebSocketController('ws://192.168.0.103:3000');

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showJoystick) {
      updateJoyStick();
    }

    super.update(dt);
  }

  void sendPositions() {
    final player1Pos = 'Player1: ${host.position}';

    webSocketManager.sendMessage(player1Pos);
  }

  @override
  void onRemove() {
    // 게임이 종료될 때 웹 소켓 연결을 닫음
    webSocketManager.close();
    super.onRemove();
  }

  void addJoystick() {
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache("HUD/Knob.png"),
        ),
      ),
      knobRadius: 100,
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache("HUD/Joystick.png"),
        ),
      ),
      margin: const EdgeInsets.only(right: 64, bottom: 64),
    );
    add(joystick);
  }

  void updateJoyStick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.downLeft:
      case JoystickDirection.upLeft:
        host.playerDirection = PlayerDirection.left;
        break;
      case JoystickDirection.right:
      case JoystickDirection.downRight:
      case JoystickDirection.upRight:
        host.playerDirection = PlayerDirection.right;
        break;
      default:
        host.playerDirection = PlayerDirection.none;
        //idle
        break;
    }
  }
}
