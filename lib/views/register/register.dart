import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:splitpay/config.dart';
import 'package:splitpay/models/user.dart';
import 'package:splitpay/views/components/loading.dart';
import 'package:splitpay/views/tabs.dart';

class Register extends StatefulWidget {
  const Register({ Key? key }) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  int _index = 0;
  TextEditingController _name = TextEditingController();
  TextEditingController _upiId = TextEditingController();
  TextEditingController _phone = TextEditingController();
  String _upiExtension='okaxis';
  bool loading=false;

  final _formKey = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserId>(context);
    registerUser() async {
      var url = Uri.http(backend_url, '/v1/user/');
      var headers = {"content-type": "application/json"};
      var payload = {
        'uid': user.uid,
        'email': user.email,
        'name': _name.text,
        'photoURL': user.photoURL,
        'phone': _phone.text,
        'upiId': _upiId.text + '@' + _upiExtension,
      };
      String body = jsonEncode(payload);
      await http.post(
        url,
        headers: headers,
        body: body,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Register')),
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: loading?
      Loading():
      Column(
        children: [
          Theme(
            data: ThemeData(),
            child: Stepper(
              physics: ClampingScrollPhysics(),
              currentStep: _index,
              onStepCancel: () {
                if (_index > 0) {
                  setState(() {
                    _index -= 1;
                  });
                }
              },
              onStepContinue: () async {
                SystemChannels.textInput.invokeMethod('TextInput.hide');
                if(_formKey[_index].currentState!.validate()){
                  if (_index <= 1) {
                    setState(() {
                      _index += 1;
                    });
                  }else{
                    setState(() {
                      loading=true;
                    });
                    await registerUser();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => Tabs()));
                  }
                }
              },
              onStepTapped: (int index) {
                setState(() {
                  _index = index;
                });
              },
              steps: <Step>[
                Step(
                  title: const Text('Name'),
                  isActive: true,
                  state: _index > 0
                      ? StepState.complete
                      : _index == 0
                          ? StepState.editing
                          : StepState.disabled,
                  content: Form(
                    key: _formKey[0],
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: _name,
                        keyboardType: TextInputType.text,
                        validator: (val) =>
                            val!.isEmpty ? "Please enter your name" : null,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ),
                Step(
                  title: Text('Phone number'),
                  isActive: true,
                  state: _index > 1
                      ? StepState.complete
                      : _index == 1
                          ? StepState.editing
                          : StepState.disabled,
                  content: Form(
                    key: _formKey[1],
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if(val!.isEmpty)return "Please enter your mobile number";
                          else if(val.length!=10)return "Not a valid number";
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: '+91',
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ),
                Step(
                  title: const Text('Upi'),
                  isActive: true,
                  state: _index > 2
                      ? StepState.complete
                      : _index == 2
                          ? StepState.editing
                          : StepState.disabled,
                  content: Form(
                    key: _formKey[2],
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            width: 180,
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
                          style: const TextStyle(color: Colors.deepPurpleAccent),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _upiExtension = newValue!;
                            });
                          },
                          items: upiExtensions.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: TextStyle(fontSize: 17),),
                            );
                          }).toList(),
                        ),
                      ],
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
