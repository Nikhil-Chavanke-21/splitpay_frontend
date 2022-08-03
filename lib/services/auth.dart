import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:splitpay/config.dart';
import 'package:splitpay/models/user.dart';
import 'package:http/http.dart' as http;

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

  updateUser(uid, registrationToken) async {
    var url = Uri.http(backend_url, '/v1/user/' + uid);
    var headers = {"content-type": "application/json"};
    var payload = {
      'registrationToken': registrationToken,
    };
    String body = jsonEncode(payload);
    await http.put(
      url,
      headers: headers,
      body: body,
    );
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

      // update regitrationToken in db
      String? token = await FirebaseMessaging.instance.getToken();
      await updateUser(user!.uid, token);

      return _userFromFirebaseUser(user);
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