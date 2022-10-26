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

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: loading?
      Loading():
      Column(
        children: <Widget>[
          SizedBox(
            height: 30.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 0, 5, 0),
                child: SizedBox(
                  width: 160,
                  child: Text(
                    'Add Payment',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 40,
                    ),
                  ),
                ),
              ),
              Image(
                image: AssetImage('assets/images/info.png'),
                width: 200,
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List<Widget>.from(categories.map((entry) {
                return _category == entry
                    ? Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorLight,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.deepPurpleAccent,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor:
                                    Theme.of(context).primaryColorLight,
                                child: Icon(
                                  categoryIcon[entry],
                                  size: 15,
                                  color: categoryColor[entry],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                child: Text(
                                  entry,
                                  style: TextStyle(
                                      color: Colors.deepPurpleAccent),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          setState(() {
                            _category = entry;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColorLight,
                            radius: 15,
                            child: Icon(
                              categoryIcon[entry],
                              size: 15,
                              color: categoryColor[entry],
                            ),
                          ),
                        ),
                      );
              })),
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
                        backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
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
                          Navigator.pushReplacement(
                            context,
                            new MaterialPageRoute(
                              builder: (context) => new CheckOut(
                                amount: amount,
                                description: _description.text,
                                category: _category,
                                upiApp: '',
                                payeeName: '',
                                payeeUpi: '',
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
