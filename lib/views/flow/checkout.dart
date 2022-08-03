import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:splitpay/config.dart';
import 'package:splitpay/models/user.dart';
import 'package:splitpay/views/flow/add_spenders.dart';

class CheckOut extends StatefulWidget {
  const CheckOut({ Key? key, this.amount, this.description, this.category, this.upiApp, this.payeeName, this.payeeUpi}) : super(key: key);
  final amount;
  final description;
  final category;
  final upiApp;
  final payeeName;
  final payeeUpi;

  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {

  addExpense(amount, payeeUpi, payeeName, payer, upiApp, description, category) async {
    var url = Uri.http(backend_url, '/v1/expense/');
    var headers = {"content-type": "application/json"};
    var payload = {
      'amount': amount,
      'payeeUpi': payeeUpi,
      'payeeName': payeeName,
      'payer': payer,
      'upiApp': upiApp,
      'description': description,
      'category': category,
    };
    String body = jsonEncode(payload);
    await http.post(
      url,
      headers: headers,
      body: body,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserId>(context);
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await addExpense(
                  widget.amount,
                  widget.payeeUpi,
                  widget.payeeName,
                  user.uid,
                  widget.upiApp,
                  widget.description,
                  widget.category,
                );
                Navigator.pop(context);
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.deepPurpleAccent),
              ),
              child: Container(
                height: 80,
                width: 200,
                child: Center(
                  child: Text(
                    'Add Expense',
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 50,),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => new AddSpenders(
                      uid: user.uid,
                      name: user.name,
                      amount: widget.amount,
                      description: widget.description,
                      category: widget.category,
                      upiApp: widget.upiApp,
                      payeeName: widget.payeeName,
                      payeeUpi: widget.payeeUpi,
                    ),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.deepPurpleAccent),
              ),
              child: Container(
                height: 80,
                width: 200,
                child: Center(
                  child: Text(
                    'Split Payment',
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
