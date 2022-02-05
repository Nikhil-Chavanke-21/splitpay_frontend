import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:splitpay/models/user.dart';

class AuthService {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserId _userFromFirebaseUser(User ?user) {
    const _null=null;
    if (user != null) {
      return UserId(
            uid: user.uid,
            name: user.displayName,
            email: user.email,
            photoURL: user.photoURL,
            creationTime: user.metadata.creationTime,
            lastSignInTime: user.metadata.lastSignInTime);
    } else {
      return _null;
    }
  }

  // auth change user stream
  Stream<UserId> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  //  Sign In with Google
  Future signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleUser!.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);
      User? user = (await _auth.signInWithCredential(credential)).user;
      return _userFromFirebaseUser(user!);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //  Log out
  Future signOut() async {
    try {
      await googleSignIn.disconnect();
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}