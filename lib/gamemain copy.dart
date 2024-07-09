// import 'package:flutter/material.dart';
// import 'package:flame/game.dart';
// import 'package:pika_client_flutter/controller/server_controller.dart';
// import 'package:pika_client_flutter/gamedialog.dart';
// import 'package:pika_client_flutter/hostgame.dart';
// // import 'package:pika_client_flutter/visitorgame.dart';

// class VolleyballGameWidget extends StatefulWidget {
//   final String role;
//   final String myId;
//   final String hostId;
//   final dynamic userinfo;

//   const VolleyballGameWidget({
//     Key? key,
//     required this.role,
//     required this.myId,
//     required this.hostId,
//     this.userinfo,
//   }) : super(key: key);

//   @override
//   VolleyballGameWidgetState createState() => VolleyballGameWidgetState();
// }

// class VolleyballGameWidgetState extends State<VolleyballGameWidget> {
//   bool isVisitorEnter = false;
//   bool isWaiting = true;
//   bool isBanned = false;
//   bool isError = false;
//   bool gameEnd = false;
//   String reason = "";

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }

//   void whenVisitorEnter(String id, VolleyballGame game) async {
//     dynamic userinfo = await getData('http://192.168.0.103:3001/api/user/$id');
//     showDialog(
//         context: context,
//         builder: (context) => VisitorEnterDialog(
//               userinfo: userinfo,
//               game: game,
//               hostId: widget.hostId,
//               myId: widget.myId,
//             ));
//   }

//   void showWaitingDialog(VolleyballGame game) {
//     showDialog(
//       context: context,
//       builder: (context) => WaitingDialog(
//         role: widget.role,
//         game: game,
//         hostId: widget.hostId,
//         myId: widget.myId,
//       ),
//     );
//   }

//   void setGameEnd(bool isEnd) {
//     setState(() {
//       gameEnd = isEnd;
//     });
//   }

//   void setIsBanned() {
//     setState(() {
//       isBanned = true;
//     });
//   }

//   void setIsErrorAndReason(String why) {
//     setState(() {
//       reason = why;

//       isBanned = true;
//     });
//   }

//   void exitGame() {
//     //dynamic info = widget.userinfo;
//     Navigator.pop(context);
//     /*
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//           builder: (context) => MainScreen(
//                 userinfo: info,
//               )),
//     );
//     */
//   }

//   Center youAreBannedDialog(VolleyballGame game) {
//     return Center(
//       child: AlertDialog(
//         title: const Text('거절'),
//         content: const Text('입장을 거절 당하셨습니다.'),
//         actions: [
//           TextButton(
//             onPressed: () =>
//                 {game.webSocketManager.outRoom(widget.hostId, widget.myId)},
//             child: const Text('확인'),
//           ),
//         ],
//       ),
//     );
//   }

//   Center enterErrorDialog(VolleyballGame game) {
//     return Center(
//       child: AlertDialog(
//         title: const Text('에러'),
//         content: Column(
//           children: [Text(reason), const Text("게임에서 나갑니다.")],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () =>
//                 {game.webSocketManager.outRoom(widget.hostId, widget.myId)},
//             child: const Text('확인'),
//           ),
//         ],
//       ),
//     );
//   }

//   Center endingDialog(VolleyballGame game) {
//     return Center(
//       child: AlertDialog(
//         title: const Text('경기 끝'),
//         content: const Column(
//           children: [
//             CircularProgressIndicator(),
//             Text("승자는 20점을 얻고 패자는 20점을 잃습니다."),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () =>
//                 {game.webSocketManager.outRoom(widget.hostId, widget.myId)},
//             child: Text('나가기'),
//           ),
//         ],
//       ),
//     );
//   }

// }
