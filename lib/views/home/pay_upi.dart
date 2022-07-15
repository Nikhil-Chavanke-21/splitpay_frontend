import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:splitpay/config.dart';
import 'package:splitpay/models/user.dart';
import 'package:splitpay/views/flow/checkout.dart';
import 'package:upi_india/upi_india.dart';
import 'package:intent/intent.dart' as android_intent;
import 'package:intent/action.dart' as android_action;

class PayUPI extends StatefulWidget {
  PayUPI({ Key? key }) : super(key: key);

  @override
  _PayUPIState createState() => _PayUPIState();
}

class _PayUPIState extends State<PayUPI> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _upiId = TextEditingController();
  String _upiExtension = 'okaxis';
  
  TextEditingController _amountController = TextEditingController();
  TextEditingController _description = TextEditingController();
  String _category = 'others';

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

  addTransaction(payeeName, payeeUpi, payer, upiApp, amount, description, category) async {
    var url = Uri.http(backend_url, '/v1/transaction/');
    var headers = {"content-type": "application/json"};
    var payload = {
        "amount": amount,
        "payeeUpi": payeeUpi,
        "payeeName": payeeName,
        "payer": payer,
        "upiApp": upiApp,
        "description": description,
        "category": category,
    };
    String body = jsonEncode(payload);
    Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    return response.body;
  }

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

  Widget displayUpiApps(BuildContext context) {
    final user = Provider.of<UserId>(context);

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
                    if (_formKey.currentState!.validate()) {
                      double amount = double.parse(_amountController.text);
                      var upi = _upiId.text + '@' + _upiExtension;

                      android_intent.Intent()
                        ..setPackage(app.packageName)
                        ..setAction(android_action.Action.ACTION_VIEW)
                        ..setData(Uri.parse('upi://pay?pa=${upi}&pn=Unknown&cu=INR&mode=02&am=${amount}'))
                        ..startActivity().catchError((e) => print(e));

                      setState(() {
                        loading=true;
                      });
                      String tid = await addTransaction(
                        '',
                        upi,
                        user.uid,
                        app.packageName,
                        amount,
                        _description.text,
                        _category,
                      );
                      setState(() {
                        loading=false;
                      });
                      Navigator.pushReplacement(
                        context,
                        new MaterialPageRoute(
                          builder: (context) => new CheckOut(
                            tid: tid,
                            amount: amount,
                            uid: user.uid,
                          ),
                        ),
                      );
                    }
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
          SizedBox(height: 100.0,),
          Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        width: 200,
                        child: TextFormField(
                          controller: _upiId,
                          keyboardType: TextInputType.text,
                          validator: (val) =>
                              val!.isEmpty ? "Please enter upi id" : null,
                          decoration: InputDecoration(
                            labelText: 'Upi Id',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0.0, horizontal: 10.0),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '@',
                      style: TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _upiExtension,
                      icon: Container(),
                      elevation: 16,
                      style: const TextStyle(
                        color: Colors.deepPurpleAccent,
                      ),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _upiExtension = newValue!;
                        });
                      },
                      items: upiExtensions
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(fontSize: 17),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    width: 320,
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        return val!.isEmpty ? "Please enter upi id":
                        double.parse(val.toString()) ==0 ?"Amount can't be 0" : null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    width: 320,
                    child: TextFormField(
                      controller: _description,
                      keyboardType: TextInputType.text,
                      validator: (val) {
                        return val!.isEmpty ? "Please enter description" : null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Description',
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 10.0),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    width: 320,
                    child: SelectFormField(
                      type: SelectFormFieldType.dropdown,
                      initialValue: _category,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          categoryIcon[_category],
                          color: categoryColor[_category],
                        ),
                        suffixIcon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.deepPurpleAccent,
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: categories
                          .map((cat) => {
                                'value': cat,
                                'label': cat,
                                'icon': Icon(
                                  categoryIcon[cat],
                                  color: categoryColor[cat],
                                ),
                              })
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _category = val;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
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