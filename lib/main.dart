import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:splitpay/models/user.dart';
import 'package:splitpay/views/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:splitpay/services/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  const _initialData = null;
  runApp(StreamProvider<UserId>.value(
    value: AuthService().user,
    initialData: _initialData,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xffFFA400),
        accentColor: Colors.white,
        backgroundColor: Color(0xff373A36),
        primaryColorDark: Colors.black,

        // Define the default font family.
        fontFamily: 'Poppins',

        // Define the default `TextTheme`. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        // textTheme: const TextTheme(
        //   headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        //   headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
        //   bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        // ),
      ),
      home: Wrapper(),
    ),
  ));
}
