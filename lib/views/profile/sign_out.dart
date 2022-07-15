import 'package:flutter/material.dart';
import 'package:splitpay/services/auth.dart';

class SignOut extends StatelessWidget {
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180.0,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 0.0),
                child: Icon(Icons.close),
              ),
            ),
          ),
          Text(
            'Sign Out',
            style: TextStyle(fontSize: 30.0),
          ),
          SizedBox(
            height: 5.0,
          ),
          Text(
            'Are you sure you want to sign out?',
            style: TextStyle(fontSize: 20.0),
          ),
          SizedBox(
            height: 15.0,
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _auth.signOut();
            },
            child: Text('Sign Out', style: TextStyle(fontSize: 25.0)),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
