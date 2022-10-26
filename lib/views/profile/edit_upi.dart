import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:splitpay/config.dart';
import 'package:http/http.dart' as http;
import 'package:splitpay/views/components/loading.dart';

class EditUPI extends StatefulWidget {
  const EditUPI({ Key? key, this.upi, this.uid, this.setUPI }) : super(key: key);
  final upi;
  final uid;
  final setUPI;

  @override
  State<EditUPI> createState() => _EditUPIState();
}

class _EditUPIState extends State<EditUPI> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _upi = TextEditingController();
  bool loading = false;
  
  TextEditingController _upiId = TextEditingController();
  String ?_upiExtension;

  @override
  void initState() {
    _upiId.text=widget.upi.split('@')[0];
    _upiExtension=widget.upi.split('@')[1];
    super.initState();
  }

  updateUser(upi) async {
    var url = Uri.http(backend_url, '/v1/user/' + widget.uid);
    var headers = {"content-type": "application/json"};
    var payload = {
      'upi': upi,
    };
    String body = jsonEncode(payload);
    await http.put(
      url,
      headers: headers,
      body: body,
    );
  }

  @override
  Widget build(BuildContext context) {
    return loading
    ? Loading()
    : Container(
      height: 500,
      child: Column(
        children: [
          SizedBox(
            height: 40,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Form(
                key: _formKey,
                child: Row(
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
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.deepPurpleAccent),
                    ),
                    child: Container(
                      width: 80,
                      alignment: Alignment.center,
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.deepPurpleAccent),
                    ),
                    child: Container(
                      width: 80,
                      alignment: Alignment.center,
                      child: Text(
                        "Update",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          loading = true;
                        });
                        String upiID=_upiId.text+'@'+_upiExtension!;
                        await updateUser(upiID);
                        widget.setUPI(upiID);
                        Fluttertoast.showToast(
                            msg: 'edited UPI',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black87,
                            textColor: Colors.white,
                            fontSize: 16.0);
                        Navigator.pop(context);
                      } else {
                        Fluttertoast.showToast(
                            msg: 'Please enter a valid UPI',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black87,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}