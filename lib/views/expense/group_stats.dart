import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:splitpay/config.dart';
import 'package:http/http.dart' as http;
import 'package:splitpay/views/components/loading.dart';

class GroupStats extends StatefulWidget {
  const GroupStats({ Key? key, this.uid }) : super(key: key);
  final uid;

  @override
  State<GroupStats> createState() => _GroupStatsState();
}

class _GroupStatsState extends State<GroupStats> {
  bool loading = true;
  List? groupExpenses;

  @override
  void initState() {
    // TODO: implement initState
    _getExpenses();
    super.initState();
  }

  _getExpenses() async {
    var url = Uri.http(backend_url, '/v1/user/stats/group/' + widget.uid);
    List response = json.decode((await http.get(url)).body);
    groupExpenses = response;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text('Group Expenses'),
        centerTitle: true,
      ),
      body: loading==true ?
      Loading():
      Container(
        height: 100,
        child: ListView(
          children: List<Widget>.from(groupExpenses!.map((entry) {
            return Padding(
              padding: EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 20.0,
                    backgroundImage:
                        NetworkImage(entry['photoURL']),
                  ),
                  title: Text(
                    entry['name'],
                    style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Text(
                    '₹ '+entry['expense'].toString(),
                    style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          })),
        ),
      ),
    );
  }
}