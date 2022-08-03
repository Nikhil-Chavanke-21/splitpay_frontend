import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:splitpay/config.dart';
import 'package:http/http.dart' as http;
import 'package:splitpay/models/user.dart';
import 'package:splitpay/views/components/loading.dart';

class AddGroup extends StatefulWidget {
  const AddGroup({ Key? key, this.uid }) : super(key: key);
  final uid;

  @override
  State<AddGroup> createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {
  List ?friends;
  bool loading=true;
  Map selected={};
  TextEditingController _groupName=TextEditingController();
  final _formKey=GlobalKey<FormState>();
  
  @override
  void initState() {
    _getFriends();
    super.initState();
  }

  _getFriends() async {
    var url = Uri.http(
        backend_url, '/v1/user/friends/'+widget.uid);
    List response = json.decode((await http.get(url)).body);
    friends = response;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    createGroup(name, selected) async {
      selected.add(widget.uid);
      var url = Uri.http(backend_url, '/v1/group/');
      var headers = {"content-type": "application/json"};
      var payload = {
        "name": name,
        "members": selected,
      };
      String body = jsonEncode(payload);
      await http.post(
        url,
        headers: headers,
        body: body,
      );
    }

    return Container(
      height: 500,
      child: Column(
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 200,
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _groupName,
                    keyboardType: TextInputType.text,
                    validator: (val) =>
                        val!.isEmpty ? "Please enter group name" : null,
                    decoration: InputDecoration(
                      labelText: 'Group Name',
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.deepPurpleAccent),
                ),
                child: Text(
                  "Create",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if(selected.length==0){
                      Fluttertoast.showToast(
                          msg: 'Please select members',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black87,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    } else {
                      await createGroup(_groupName.text, selected.keys.toList());
                      Navigator.pop(context);
                    }
                  } else {
                    Fluttertoast.showToast(
                        msg: 'Please enter group name',
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: Container(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List<Widget>.from(selected.keys.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: InkWell(
                      onTap: (){
                        setState(() {
                          selected.remove(entry);
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: CachedNetworkImage(
                                imageUrl: selected[entry],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => new CircularProgressIndicator(),
                                errorWidget: (context, url, error) => new Icon(Icons.error),
                              ),
                            ),
                            Align(
                              alignment: Alignment(1, 1),
                              child: CircleAvatar(
                                radius: 8,
                                backgroundColor: Colors.grey,
                                child: Icon(
                                  Icons.clear,
                                  size: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                })),
              ),
            ),
          ),
          Divider(),
          loading ? Loading()
          :Expanded(
            child: ListView.builder(
              itemCount: friends!.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: (){
                    setState(() {
                      selected[friends![index]['id']]=friends![index]['photoURL'];
                    });
                  },
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: CachedNetworkImage(
                          imageUrl: friends![index]['photoURL'],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => new CircularProgressIndicator(),
                          errorWidget: (context, url, error) => new Icon(Icons.error),
                        ),
                      ),
                    ),
                    title: Text(friends![index]['name']),
                  ),
                );
            }),
          ),
        ],
      ),
    );
  }
}
