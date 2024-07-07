import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pika_client_flutter/components/ball.dart';
import 'package:pika_client_flutter/components/ball_clone.dart';
import 'package:pika_client_flutter/components/dummy_player.dart';
import 'package:pika_client_flutter/components/overlay.dart';
import 'package:pika_client_flutter/components/ready.dart';
import 'package:pika_client_flutter/components/score.dart';
import 'package:pika_client_flutter/components/spike_button.dart';
import 'package:pika_client_flutter/controller/web_socket_controller.dart';
import 'package:pika_client_flutter/components/map.dart';
import 'package:pika_client_flutter/components/player.dart';

class VolleyballGame extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        TapCallbacks,
        HasCollisionDetection {
  late WebSocketController webSocketManager;
  PikaPlayer host = PikaPlayer();
  PikaDummyPlayer visitor = PikaDummyPlayer();
  PikaBall ball = PikaBall();
  PikaBallClone spike = PikaBallClone("spike");
  PikaBallClone shadow1 = PikaBallClone("shadow1");
  PikaBallClone shadow2 = PikaBallClone("shadow2");
  Score hostScore = Score();
  Score visitorScore = Score();
  Ready ready1 = Ready();
  final String role;
  double slow = 1;
  DarkOverlayComponent darkOverlay = DarkOverlayComponent();

  late final CameraComponent cam;
  late JoystickComponent joystick;
  bool showControls = true;

  VolleyballGame(this.role);
  @override
  Color backgroundColor() => const Color.fromARGB(255, 0, 0, 0);

  @override
  Future<void> onLoad() async {
    await images.loadAllImages();

    final world = PikaMap(
      player: (role == "host") ? host : visitor,
      player2: (role == "host") ? visitor : host,
      ball: ball,
      spike: spike,
      shadow1: shadow1,
      shadow2: shadow2,
      role: role,
      hostScore: hostScore,
      visitorScore: visitorScore,
      ready: ready1,
      darkOverlay: darkOverlay,
    );
    cam = CameraComponent.withFixedResolution(
      world: world,
      width: 432,
      height: 304,
    );
    cam.viewfinder.anchor = Anchor.topLeft;

    add(cam);
    add(world);

    if (showControls) {
      addJoystick();
      add(SpikeButton());
    }

    webSocketManager =
        WebSocketController('ws://192.168.0.103:3000', visitor, ball);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls) {
      updateJoyStick();
    }

    if (slow == 0.3) {
      darkOverlay.darken(0.02);
    }

    super.update(dt * slow);
  }

  @override
  void onRemove() {
    // 게임이 종료될 때 웹 소켓 연결을 닫음
    webSocketManager.close();
    super.onRemove();
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 10,
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
        host.horizontalMovement = -1;
        host.left = true;
        host.right = false;
        host.up = false;
        host.down = false;
        break;
      case JoystickDirection.downLeft:
        host.horizontalMovement = -1;
        host.left = true;
        host.right = false;
        host.up = false;
        host.down = true;
        break;
      case JoystickDirection.upLeft:
        host.isJumping = true;
        host.isDashing = false;
        host.horizontalMovement = -1;
        host.left = true;
        host.right = false;
        host.up = true;
        host.down = false;
        break;
      case JoystickDirection.right:
        host.horizontalMovement = 1;
        host.left = false;
        host.right = true;
        host.up = false;
        host.down = false;
        break;
      case JoystickDirection.downRight:
        host.horizontalMovement = 1;
        host.left = false;
        host.right = true;
        host.up = false;
        host.down = true;
        break;
      case JoystickDirection.upRight:
        host.isJumping = true;
        host.isDashing = false;
        host.horizontalMovement = 1;
        host.left = false;
        host.right = true;
        host.up = true;
        host.down = false;
        break;
      case JoystickDirection.up:
        host.isJumping = true;
        host.isDashing = false;
        host.left = false;
        host.right = false;
        host.up = true;
        host.down = false;
        break;
      case JoystickDirection.down:
        host.isJumping = true;
        host.isDashing = false;
        host.left = false;
        host.right = false;
        host.up = false;
        host.down = true;
        break;
      case JoystickDirection.downLeft:
        host.isJumping = true;
        host.isDashing = false;
        host.left = true;
        host.right = false;
        host.up = false;
        host.down = true;
        break;
      case JoystickDirection.downRight:
        host.isJumping = true;
        host.isDashing = false;
        host.left = false;
        host.right = true;
        host.up = false;
        host.down = true;
        break;
      default:
        host.horizontalMovement = 0;
        host.isJumping = false;
        host.left = false;
        host.right = false;
        host.up = false;
        host.down = false;
        //idle
        break;
    }
  }
}
