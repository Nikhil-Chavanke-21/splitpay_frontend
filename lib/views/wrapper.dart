import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitpay/models/user.dart';
import 'package:splitpay/views/login.dart';
import 'package:splitpay/views/tabs.dart';
// import 'package:splitpay/views/register/register.dart';
// import 'package:splitpay/views/sign_in/sign_in.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserId>(context);
    // return Tabs();
    if (user == null) {
      return LoginScreen();
    // } else if (user.lastSignInTime.difference(user.creationTime).inSeconds <
    //     1) {
    //   return Register();
    } else {
      return Tabs();
    }
  }
}
