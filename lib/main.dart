import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:splitpay/models/user.dart';
import 'package:splitpay/views/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:splitpay/services/auth.dart';

void main() async {
  // initialize firebase app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // set potrait orientation
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  const _initialData = null;

  // run app
  runApp(StreamProvider<UserId>.value(
    value: AuthService().user,
    initialData: _initialData,
    child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SplitPay',
          theme: ThemeData(
            primaryColor: Color(0xff6750A4),
            primaryColorLight: Color(0xffD0BCFF),
            accentColor: Color(0xff6750A4),
            cardColor: Color(0xff6750A4),
          ),
          home: Wrapper(),
        ),
  ));
}
