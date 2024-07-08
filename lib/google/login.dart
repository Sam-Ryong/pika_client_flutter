import 'package:google_sign_in/google_sign_in.dart';

Future<GoogleSignInAccount?> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  if (googleUser != null) {
    //print('name = ${googleUser.displayName}');
    //print('email = ${googleUser.email}');
    //print('id = ${googleUser.id}');
    return googleUser;
  } else {
    return null;
  }
}
