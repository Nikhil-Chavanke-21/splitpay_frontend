import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:splitpay/config.dart';
import 'package:splitpay/views/components/loading.dart';
import 'package:splitpay/views/ledger/settle.dart';

class GroupLogs extends StatefulWidget {
  const GroupLogs({Key? key, this.id, this.name, this.photoURL, this.uid}): super(key: key);

  final id;
  final name;
  final photoURL;
  final uid;

  @override
  _GroupLogsState createState() => _GroupLogsState();
}

class _GroupLogsState extends State<GroupLogs> {
  bool loading = true;
  List? logs;
  Map? dues;

  @override
  void initState() {
    // TODO: implement initState
    _getTransactions();
    super.initState();
  }

  _getTransactions() async {
    Map<String, dynamic> query = {
      'group': widget.id,
    };
    var url = Uri.http(
        backend_url, '/v1/transaction/'+widget.uid, query);
    List response = json.decode((await http.get(url)).body);
    logs = response;

    query = {
      'group': widget.id,
      'user': widget.uid,
    };
    url = Uri.http(backend_url, '/v1/group/dues/', query);
    Map response1 = json.decode((await http.get(url)).body);
    dues = response1;
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(dues);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Row(
          children: [
            widget.photoURL != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(widget.photoURL),
                  )
                : CircleAvatar(
                        backgroundColor: Colors.green[700],
                        child: Icon(
                          Icons.group_outlined,
                          color: Colors.white,
                        ),
                      ),
            SizedBox(
              width: 10.0,
            ),
            Text(widget.name),
          ],
        ),
      ),
      body: loading == true
          ? Loading()
          : SafeArea(
              child: Container(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      child: Container(
                        height: 75,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: List<Widget>.from(dues!.keys.map((x) {
                            return Padding(
                              padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 25.0,
                                    backgroundImage:
                                        NetworkImage(dues![x]['photoURL']),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        dues![x]['due'].toString(),
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                          color: dues![x]['due'] > 0
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      dues![x]['due'] > 0
                                          ? Icon(
                                              Icons.call_received,
                                              color: Colors.green,
                                            )
                                          : Icon(
                                              Icons.call_made,
                                              color: Colors.red,
                                            ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList()),
                        ),
                      ),
                    ),
                    Divider(),
                    Expanded(
                      child: ListView.builder(
                          reverse: true,
                          itemCount: logs!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return LogItem(
                              logs![index]['amount'].toDouble(),
                              logs![index]['isMine'],
                              logs![index]['expense'].toDouble(),
                              DateTime.fromMillisecondsSinceEpoch(
                                  logs![index]['time'] * 1000),
                            );
                          }),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget LogItem(double amount, bool isMine, double expense, DateTime time) {
    String formattedDate = time.year != DateTime.now().year
        ? time.year.toString()
        : time.month != DateTime.now().month || time.day != DateTime.now().day
            ? DateFormat("dd/MM").format(time).toString()
            : DateFormat("h:mm a").format(time).toString().toLowerCase();
    String due = '₹ ' +
        (!isMine
            ? expense.toInt().toString()
            : (amount - expense).toInt().toString());
    String paidBy = isMine ? 'You' : widget.name.split(' ')[0];
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ListTile(
        title: Align(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 200.0,
            height: 130.0,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).accentColor.withOpacity(0.3),
                  blurRadius: 1,
                  offset: Offset(2.0, 2.0),
                ),
              ],
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(formattedDate),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '₹ ' + amount.toInt().toString(),
                    style: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Domino's Pizza"),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Paid by '),
                    Text(
                      paidBy,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Text(
                      due,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isMine ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        onTap: () {},
      ),
    );
  }
}
