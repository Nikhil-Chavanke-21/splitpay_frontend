import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:splitpay/config.dart';
import 'package:splitpay/models/user.dart';
import 'package:splitpay/views/components/loading.dart';
import 'package:splitpay/views/flow/split.dart';

class AddSpenders extends StatefulWidget {
  const AddSpenders({ Key? key, this.tid, this.amount, this.uid }) : super(key: key);
  final tid;
  final uid;
  final amount;
  @override
  _AddSpendersState createState() => _AddSpendersState();
}

class _AddSpendersState extends State<AddSpenders> {
  Map selectedFriends = {};
  Map selectedGroups = {};
  bool loading = true;
  List? contacts;

  @override
  void initState() {
    // TODO: implement initState
    _getContacts();
    super.initState();
  }

  _getContacts() async {
    var url = Uri.http(
        backend_url, '/v1/user/contacts/' + widget.uid);
    List response = json.decode((await http.get(url)).body);
    contacts = response.map((e) {
      e['isSelected'] = false;
      return e;
    }).toList();
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text("Split with..."),
        centerTitle: true,
      ),
      body: loading == true
          ? Loading()
          : SafeArea(
              child: Container(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          itemCount: contacts!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return MemberItem(
                              contacts![index]['id'],
                              contacts![index]['name'],
                              contacts![index]['photoURL'],
                              contacts![index]['isSelected'],
                              contacts![index]['isGroup'],
                              index,
                            );
                          }),
                    ),
                    selectedFriends.length + selectedGroups.length > 0
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 10,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.deepPurpleAccent),
                                ),
                                child: Text(
                                  "Split (${selectedFriends.length + selectedGroups.length})",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    loading = true;
                                  });
                                  Map selectedMembers = await getMembers();
                                  setState(() {
                                    loading = false;
                                  });
                                  Navigator.pushReplacement(
                                    context,
                                    new MaterialPageRoute(
                                      builder: (context) => new Split(
                                        members: selectedMembers,
                                        tid: widget.tid,
                                        amount: widget.amount,
                                        uid: widget.uid,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget MemberItem(String id, String name, String photoURL, bool isSelected,
      bool isGroup, int index) {
    return ListTile(
      leading: photoURL != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(photoURL),
            )
          : isGroup
              ? CircleAvatar(
                  backgroundColor: Colors.deepPurpleAccent,
                  child: Icon(
                    Icons.group_outlined,
                    color: Colors.white,
                  ),
                )
              : CircleAvatar(
                  backgroundColor: Colors.deepPurpleAccent,
                  child: Icon(
                    Icons.person_outline_outlined,
                    color: Colors.white,
                  ),
                ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Colors.deepPurpleAccent,
            )
          : Icon(
              Icons.check_circle_outline,
              color: Colors.grey,
            ),
      onTap: () {
        setState(() {
          contacts![index]['isSelected'] = !contacts![index]['isSelected'];
          if (contacts![index]['isSelected'] == true) {
            if (isGroup)
              selectedGroups[id] = name;
            else
              selectedFriends[id] = name;
          } else if (contacts![index]['isSelected'] == false) {
            if (isGroup)
              selectedGroups.remove(id);
            else
              selectedFriends.remove(id);
          }
        });
      },
    );
  }

  getMembers() async {
    var url = Uri.http(backend_url, '/v1/group/members/');
    var headers = {"content-type": "application/json"};
    var payload = {
      'friends': selectedFriends.keys.join(','),
      'groups': selectedGroups.keys.join(','),
    };
    String body = jsonEncode(payload);
    Response response = await http.post(
      url,
      headers: headers,
      body: body,
    );
    return json.decode(response.body);
  }
}
