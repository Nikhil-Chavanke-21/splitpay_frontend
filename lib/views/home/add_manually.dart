import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:splitpay/config.dart';
import 'package:splitpay/models/user.dart';
import 'package:splitpay/views/flow/checkout.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:splitpay/views/components/loading.dart';

class AddManually extends StatefulWidget {
  AddManually({Key? key}) : super(key: key);

  @override
  _AddManuallyState createState() => _AddManuallyState();
}

class _AddManuallyState extends State<AddManually> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _description = TextEditingController();
  String _category='others';

  bool loading = false;

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
  Widget build(BuildContext context) {
    final user = Provider.of<UserId>(context);
    
    return Scaffold(
      body: loading?
      Loading():
      Column(
        children: <Widget>[
          SizedBox(
            height: 100.0,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
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
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    child: TextFormField(
                      controller: _description,
                      keyboardType: TextInputType.text,
                      validator: (val) {
                        return val!.isEmpty
                            ? "Please enter description"
                            : null;
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
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        return val!.isEmpty
                            ? "Please enter upi id"
                            : double.parse(val.toString()) == 0
                                ? "Amount can't be 0"
                                : null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 10.0),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurpleAccent),
                      ),
                      child: Text(
                        "Add",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      onPressed: () async {
                        if(_formKey.currentState!.validate()){
                          double amount = double.parse(_amountController.text);
                          setState(() {
                            loading = true;
                          });
                          String tid = await addTransaction(
                            '',
                            '',
                            user.uid,
                            '',
                            amount,
                            _description.text,
                            _category,
                          );
                          setState(() {
                            loading = false;
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
