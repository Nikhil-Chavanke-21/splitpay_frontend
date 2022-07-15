import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:intent/intent.dart' as android_intent;
import 'package:intent/action.dart' as android_action;
import 'package:provider/provider.dart';
import 'package:splitpay/config.dart';
import 'package:splitpay/models/user.dart';
import 'package:upi_india/upi_india.dart';

class Settle extends StatefulWidget {
  const Settle({ Key? key, this.amount, this.id, this.upi, this.name, this.setDue, this.uid }) : super(key: key);

  final amount;
  final upi;
  final name;
  final id;
  final setDue;
  final uid;

  @override
  _SettleState createState() => _SettleState();
}

class _SettleState extends State<Settle> {
  bool loading = false;

  Future<UpiResponse>? _transaction;
  UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? apps;

  TextStyle header = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  TextStyle value = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

  @override
  void initState() {
    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        apps = value;
      });
    }).catchError((e) {
      apps = [];
    });
    
    super.initState();
  }

  settleFriend(from, to, upiApp, amount) async {
    var url = Uri.http(backend_url, '/v1/transaction/settle/');
    var headers = {"content-type": "application/json"};
    var payload = {
        "amount": amount,
        "from": from,
        "to": to,
        "upiApp": upiApp,
    };
    String body = jsonEncode(payload);
    await http.post(
      url,
      headers: headers,
      body: body,
    );
  }

  Map<String, String> splitQueryString(String query) {
    return query.split("&").fold({}, (map, element) {
      int index = element.indexOf("=");
      if (index == -1) {
        if (element != "") {
          map[element] = "";
        }
      } else if (index != 0) {
        var key = element.substring(0, index);
        var value = element.substring(index + 1);
        map[key] = value.replaceAll('%20', ' ');
      }
      return map;
    });
  }

  Widget displayUpiApps(BuildContext context) {
    if (apps == null || loading)
      return Center(child: CircularProgressIndicator());
    else if (apps!.length == 0)
      return Center(
        child: Text(
          "No apps found to handle transaction.",
          style: header,
        ),
      );
    else
      return Padding(
        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Wrap(
              children: apps!.map<Widget>((UpiApp app) {
                return GestureDetector(
                  onTap: () async {
                    setState(() {
                      loading=true;
                    });
                    try {
                      android_intent.Intent()
                        ..setPackage(app.packageName)
                        ..setAction(android_action.Action.ACTION_VIEW)
                        ..setData(Uri.parse(
                            'upi://pay?pa=${widget.upi}&pn=${widget.name.replaceAll(' ', '%20')}&cu=INR&mode=02&am=${widget.amount}'))
                        ..startActivity();

                      await settleFriend(widget.uid, widget.id, app.packageName, widget.amount);
                      widget.setDue();
                    } catch (e) {
                      print(e);
                    }
                    Navigator.pop(context);
                    setState(() {
                      loading=false;
                    });
                  },
                  child: Container(
                    height: 80,
                    width: 70,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.memory(
                          app.icon,
                          height: 60,
                          width: 60,
                        ),
                        Text(app.name),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
  }

  String _upiErrorHandler(error) {
    switch (error) {
      case UpiIndiaAppNotInstalledException:
        return 'Requested app not installed on device';
      case UpiIndiaUserCancelledException:
        return 'You cancelled the transaction';
      case UpiIndiaNullResponseException:
        return 'Requested app didn\'t return any response';
      case UpiIndiaInvalidParametersException:
        return 'Requested app cannot handle the transaction';
      default:
        return 'An Unknown error has occurred';
    }
  }

  void _checkTxnStatus(String status) {
    switch (status) {
      case UpiPaymentStatus.SUCCESS:
        print('Transaction Successful');
        break;
      case UpiPaymentStatus.SUBMITTED:
        print('Transaction Submitted');
        break;
      case UpiPaymentStatus.FAILURE:
        print('Transaction Failed');
        break;
      default:
        print('Received an Unknown transaction status');
    }
  }

  Widget displayTransactionData(title, body) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title: ", style: header),
          Flexible(
              child: Text(
            body,
            style: value,
          )),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(height: 40.0,),
          Text('Paying', style: TextStyle(fontSize: 20.0)),
          Text(widget.amount.toString()+ ' ₹', style: TextStyle(fontSize: 40.0)),
          Text('to', style: TextStyle(fontSize: 20.0)),
          Text(widget.name, style: TextStyle(fontSize: 30.0)),
          Text(widget.upi, style: TextStyle(fontSize: 25.0)),
          SizedBox(height: 10.0,),
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Pay using', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
            ),
          ),
          Expanded(
            child: displayUpiApps(context),
          ),
          Expanded(
            child: FutureBuilder(
              future: _transaction,
              builder: (BuildContext context, AsyncSnapshot<UpiResponse> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        _upiErrorHandler(snapshot.error.runtimeType),
                        style: header,
                      ), // Print's text message on screen
                    );
                  }

                  // If we have data then definitely we will have UpiResponse.
                  // It cannot be null
                  UpiResponse _upiResponse = snapshot.data!;

                  // Data in UpiResponse can be null. Check before printing
                  String txnId = _upiResponse.transactionId ?? 'N/A';
                  String resCode = _upiResponse.responseCode ?? 'N/A';
                  String txnRef = _upiResponse.transactionRefId ?? 'N/A';
                  String status = _upiResponse.status ?? 'N/A';
                  String approvalRef = _upiResponse.approvalRefNo ?? 'N/A';
                  _checkTxnStatus(status);

                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        displayTransactionData('Transaction Id', txnId),
                        displayTransactionData('Response Code', resCode),
                        displayTransactionData('Reference Id', txnRef),
                        displayTransactionData('Status', status.toUpperCase()),
                        displayTransactionData('Approval No', approvalRef),
                      ],
                    ),
                  );
                } else
                  return Center(
                    child: Text(''),
                  );
              },
            ),
          )
        ],
      ),
    );
  }
}