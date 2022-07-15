import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart';
import 'package:splitpay/views/components/loading.dart';
import 'package:splitpay/views/ledger/friend_logs.dart';
import 'package:http/http.dart' as http;
import 'package:splitpay/config.dart';
import 'package:splitpay/views/ledger/group_logs.dart';

class Groups extends StatefulWidget {
  const Groups({Key ?key, this.uid}) : super(key: key);
  final uid;

  @override
  _GroupsState createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  bool loading=true;
  List ?contacts;

  @override
  void initState() {
    // TODO: implement initState
    _getContacts();
    super.initState();
  }

  _getContacts() async {
    var url=Uri.http(backend_url, '/v1/user/contacts/'+widget.uid);
    List response=json.decode((await http.get(url)).body);
    contacts=response;
    setState(() {
      loading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text('Groups'),
        centerTitle: true,
        actions: [
          IconButton(
            //TODO: to implement seaarch
            onPressed: () {},
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: loading == true
          ? Loading()
          : SafeArea(
            child: Container(
              child: Expanded(
                child: ListView.builder(
                itemCount: contacts!.length,
                itemBuilder: (BuildContext context, int index) {
                  return MemberItem(
                    contacts![index]['id'],
                    contacts![index]['name'],
                    contacts![index]['photoURL'],
                    contacts![index]['isGroup'],
                    index,
                  );
                }),
              ),
            ),
          ),
    );
  }
  Widget MemberItem(
      String id, String name, String photoURL, bool isGroup, int index) {
    return ListTile(
      leading: photoURL!=null ?CircleAvatar(
        backgroundImage: NetworkImage(photoURL),
      ):isGroup?CircleAvatar(
        backgroundColor: Colors.green[700],
        child: Icon(
          Icons.group_outlined,
          color: Colors.white,
        ),
      ):CircleAvatar(
        backgroundColor: Colors.green[700],
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
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>
        isGroup?
        GroupLogs(
          id: id,
          name: name,
          photoURL: photoURL,
          uid: widget.uid,
        ):
        FriendLogs(
          id: id,
          name: name,
          photoURL: photoURL,
          upi: contacts![index]['upi'],
          due: contacts![index]['due'],
          uid: widget.uid,
        )));
      },
    );
  }
}

