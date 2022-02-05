import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitpay/models/user.dart';

class CheckOut extends StatefulWidget {
  const CheckOut({ Key? key, this.upi, this.merchant, this.mc, this.am, this.date, this.app }) : super(key: key);
  final upi;
  final merchant;
  final mc;
  final am;
  final date;
  final app;

  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserId>(context);
    
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(height: 50.0,),
          Text(widget.upi),
          Text(widget.merchant),
          Text(widget.mc==null?'':widget.mc),
          Text(widget.am.toString()),
          Text(widget.date.toString()),
          Text(widget.app),
        ],
      ),
    );
  }
}
