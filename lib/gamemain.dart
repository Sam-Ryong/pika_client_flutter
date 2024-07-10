import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:pika_client_flutter/gamedialog.dart';
import 'package:pika_client_flutter/hostgame.dart';
// import 'package:pika_client_flutter/visitorgame.dart';

class VolleyballGameWidget extends StatefulWidget {
  final String role;
  final String myId;
  final String hostId;
  final dynamic userinfo;

  const VolleyballGameWidget({
    super.key,
    required this.role,
    required this.myId,
    required this.hostId,
    this.userinfo,
  });

  @override
  VolleyballGameWidgetState createState() => VolleyballGameWidgetState();
}

class VolleyballGameWidgetState extends State<VolleyballGameWidget> {
  bool isVisitorEnter = false;
  bool isWaiting = true;
  bool isBanned = false;
  bool isError = false;
  bool gameEnd = false;
  String reason = "";

  void closeDialog() {
    Navigator.pop(context);
  }

  void whenVisitorEnter(String id, VolleyballGame game) {
    afterEnter(id, game);
  }

  void afterEnter(String id, VolleyballGame game) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => VisitorEnterDialog(
          game: game,
          hostId: widget.hostId,
          myId: widget.myId,
          id: id,
          dialog: this),
    );
  }

  void showWaitingDialog(VolleyballGame game) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => WaitingDialog(
        role: widget.role,
        game: game,
        hostId: widget.hostId,
        myId: widget.myId,
      ),
    );
  }

  void setGameEnd(VolleyballGame game) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => EndingDialog(
        role: widget.role,
        game: game,
        hostId: widget.hostId,
        myId: widget.myId,
      ),
    );
  }

  void setIsBanned(VolleyballGame game) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => YouAreBannedDialog(
        role: widget.role,
        game: game,
        hostId: widget.hostId,
        myId: widget.myId,
      ),
    );
  }

  void setIsErrorAndReason(String why, VolleyballGame game) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => EnterErrorDialog(
        role: widget.role,
        game: game,
        hostId: widget.hostId,
        myId: widget.myId,
        reason: why,
      ),
    );
  }

  void exitGame() {
    //dynamic info = widget.userinfo;
    Navigator.pop(context);
    /*
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => MainScreen(
                userinfo: info,
              )),
    );
    */
  }

  @override
  Widget build(BuildContext context) {
    final VolleyballGame game =
        VolleyballGame(widget.role, widget.myId, widget.hostId, this);

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        /*
        onPanUpdate: (details) {
          game.onPanUpdate(details.delta);
        },
        */
        child: Stack(
          children: [
            GameWidget(
              game: game,
            ),
          ],
        ),
      ),
    );
  }
}
