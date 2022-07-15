import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:splitpay/config.dart';
import 'package:http/http.dart' as http;
import 'package:splitpay/models/user.dart';
import 'package:splitpay/views/components/loading.dart';

class AddFriend extends StatefulWidget {
  const AddFriend({ Key? key, this.uid }) : super(key: key);
  final uid;

  @override
  State<AddFriend> createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _friendEmail = TextEditingController();
  bool loading=false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserId>(context);

    addFriend(friendEmail) async {
      Map<String, dynamic> query = {
        'userId': widget.uid,
        'friendEmail': friendEmail,
      };
      var url = Uri.http(backend_url, '/v1/user/friend/', query);
      Map response = json.decode((await http.get(url)).body);
      return response;
    }

    return loading?
    Loading():
    Container(
      height: 500,
      child: Column(
        children: [
          SizedBox(height: 40,),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 350,
                child: 
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _friendEmail,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) =>
                        val!.isEmpty ? "Please enter group name" : null,
                    decoration: InputDecoration(
                      labelText: 'Friend Email',
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.deepPurpleAccent),
                  ),
                  child: Container(
                    width: 80,
                    alignment: Alignment.center,
                    child: Text(
                      "Add",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  onPressed: () async {
                    if(_formKey.currentState!.validate()){
                      setState(() {
                        loading=true;
                      });
                      Map res=await addFriend(_friendEmail.text);
                      print(res);
                      String message='';
                      if(res['code']==409){
                        message=res['message'];
                        Navigator.pop(context);
                      } else if(res['code']==400){
                        message=res['message'];
                        setState(() {
                          loading = true;
                        });
                      } else {
                        message=res['message'];
                        Navigator.pop(context);
                      }
                      Fluttertoast.showToast(
                          msg: message,
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black87,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    } else {
                      Fluttertoast.showToast(
                        msg: 'Please enter a valid email',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black87,
                        textColor: Colors.white,
                        fontSize: 16.0
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 15,),
        ],
      ),
    );
  }
}