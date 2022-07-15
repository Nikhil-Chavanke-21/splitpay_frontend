import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitpay/models/user.dart';
import 'package:splitpay/views/register/register.dart';
import 'package:splitpay/views/register/sign_in.dart';
import 'package:splitpay/views/tabs.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserId>(context);
    if (user==null) {
      return SignIn();
    } else if (user.lastSignInTime!.difference(user.creationTime!).inSeconds <
        1) {
      return Register();
    } else {
      return Tabs();
    }
  }
}
