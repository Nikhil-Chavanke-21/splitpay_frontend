import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
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
  
  setDue(userId) {
    setState(() {
      dues!.remove(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Row(
          children: [
            widget.photoURL != null
                ? Container(
                  width: 40,
                  height: 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: CachedNetworkImage(
                      imageUrl: widget.photoURL,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => new CircularProgressIndicator(),
                      errorWidget: (context, url, error) => new Icon(Icons.error),
                    ),
                  ),
                ):
                CircleAvatar(
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
                              child: InkWell(
                                onTap: (){
                                  if(dues![x]['due']<0){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Settle(
                                            amount: -dues![x]['due'],
                                            id: x,
                                            upi: dues![x]['upi'],
                                            name: dues![x]['name'],
                                            setDue: setDue,
                                            uid: widget.uid,
                                            group: widget.id,
                                            photoURL: dues![x]['photoURL'],
                                          )
                                        )
                                      );
                                  }
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(25.0),
                                        child: CachedNetworkImage(
                                          imageUrl: dues![x]['photoURL'],
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => new CircularProgressIndicator(),
                                          errorWidget: (context, url, error) => new Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          dues![x]['due'].abs().toInt().toString(),
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white54,
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
                              logs![index]['category'],
                              logs![index]['description'],
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

  Widget LogItem(double amount, bool isMine, double expense, String category, String description, DateTime time) {
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
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Paid by ',
                      style: TextStyle(
                        color: Colors.white54,
                      ),
                    ),
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircleAvatar(
                        child: Icon(
                          categoryIcon[category],
                          color: categoryColor[category],
                          size: 30,
                        ),
                        radius: 25,
                        backgroundColor: Theme.of(context).backgroundColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text(
                                amount.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 26.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                child: Text(
                                  '₹',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                due,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white38,
                                ),
                              ),
                              Icon(
                                isMine ? Icons.call_received : Icons.call_made,
                                color: isMine ? Colors.green : Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(description),
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
