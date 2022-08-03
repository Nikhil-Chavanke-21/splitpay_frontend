import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:splitpay/config.dart';
import 'package:splitpay/views/components/loading.dart';
import 'package:splitpay/views/ledger/edit_transaction.dart';
import 'package:splitpay/views/ledger/settle.dart';

class FriendLogs extends StatefulWidget {
  const FriendLogs(
      {Key? key,
      this.id,
      this.name,
      this.photoURL,
      this.upi,
      this.due,
      this.uid})
      : super(key: key);

  final id;
  final name;
  final photoURL;
  final upi;
  final due;
  final uid;

  @override
  _FriendLogsState createState() => _FriendLogsState();
}

class _FriendLogsState extends State<FriendLogs> {
  bool loading = true;
  List? logs;
  String due = '0';
  int _index=-1;

  @override
  void initState() {
    setState(() {
      due = widget.due;
    });
    _getTransactions();
    super.initState();
  }

  _getTransactions() async {
    Map<String, dynamic> query = {
      'friend': widget.id,
    };

    var url = Uri.http(backend_url, '/v1/transaction/' + widget.uid, query);
    List response = json.decode((await http.get(url)).body);
    logs = response;
    setState(() {
      loading = false;
    });
  }

  setDue() {
    setState(() {
      due = '0';
    });
  }

  setIndex() {
    setState(() {
      _index = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading == true
      ? Loading()
      : Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
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
                ): CircleAvatar(
                    backgroundColor: Colors.green[700],
                    child: Icon(
                      Icons.person_outline_outlined,
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
      body: Container(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      reverse: true,
                      itemCount: logs!.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (logs![index]['type'] == 'settlement') {
                          return SettlementItem(
                            logs![index]['amount'].toDouble(),
                            logs![index]['isMine'],
                            DateTime.fromMillisecondsSinceEpoch(
                                logs![index]['time'] * 1000),
                          );
                        } else {
                          return ExpenseItem(
                            index,
                            logs![index]['amount'].toDouble(),
                            logs![index]['isMine'],
                            logs![index]['expense'].toDouble(),
                            logs![index]['category'],
                            logs![index]['description'],
                            logs![index]['split'],
                            logs![index]['transaction'],
                            DateTime.fromMillisecondsSinceEpoch(
                              logs![index]['time'] * 1000
                            ),
                          );
                        }
                      }),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  color: Theme.of(context).canvasColor,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          '₹ ' + int.parse(due).abs().toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: int.parse(due) == 0
                                ? Colors.black
                                : int.parse(due) < 0
                                    ? Colors.red
                                    : Colors.green,
                          ),
                        ),
                        int.parse(due) < 0
                            ? ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.deepPurpleAccent),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "Settle",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Settle(
                                                amount: -int.parse(due),
                                                id: widget.id,
                                                upi: widget.upi,
                                                name: widget.name,
                                                setDue: setDue,
                                                uid: widget.uid,
                                                group: null,
                                                photoURL: widget.photoURL,
                                              )));
                                },
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
  }

  Widget ExpenseItem(
      int index, double amount, bool isMine, double expense, String category, String description, split, tid, DateTime time) {
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
    return ListTile(
      tileColor: _index==index?Colors.white24: NeumorphicTheme.baseColor(context),
      title: Row(
        mainAxisAlignment: isMine? MainAxisAlignment.end: MainAxisAlignment.start,
        children: [
          _index==index && isMine?Column(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                color: Theme.of(context).canvasColor,
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditTransaction(
                        category: category,
                        description: description,
                        amount: amount,
                        split: split,
                        tid: tid,
                        setIndex: setIndex,
                      ),
                  ));
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                color: Theme.of(context).canvasColor,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(  
                        title: Text("Are you sure?"),
                        content: Text("Are you sure you want to delete this item permanently?"),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ElevatedButton(
                              child: Text('Cancel'),
                              style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Theme.of(context).canvasColor),
                                    ),
                              onPressed: (){
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ElevatedButton(
                              child: Text('Delete'),
                              style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.deepPurpleAccent),
                                    ),
                              onPressed: () {},
                            ),
                          ),
                        ],  
                      );
                    },
                  ); 
                },
              ),
            ],
          ):Container(),
          InkWell(
            onLongPress: (){
              setState(() {
                _index = index;              
              });
            },
            onTap: (){
              setState(() {
                _index = -1;
              });
            },
            child: Container(
              width: 200.0,
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).canvasColor,
                    blurRadius: 1,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
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
                          backgroundColor: NeumorphicTheme.baseColor(context),
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
          _index == index && !isMine
              ? Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      color: Theme.of(context).canvasColor,
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      color: Theme.of(context).canvasColor,
                      onPressed: () {},
                    ),
                  ],
                )
              : Container(),
        ],
      ),
      onTap: () {},
    );
  }

  Widget SettlementItem(double amount, bool isMine, DateTime time) {
    String formattedDate = time.year != DateTime.now().year
        ? time.year.toString()
        : time.month != DateTime.now().month || time.day != DateTime.now().day
            ? DateFormat("dd/MM").format(time).toString()
            : DateFormat("h:mm a").format(time).toString().toLowerCase();
    return ListTile(
      title: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 200.0,
          height: 50.0,
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Icon(
                  isMine ? Icons.call_made : Icons.call_received,
                  size: 30,
                  color: isMine ? Colors.red : Colors.green,
                ),
              ),
              Expanded(
                child: Container(),
              ),
              Text(
                //  +
                amount.toInt().toString(),
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                child: Text('₹'),
              ),
              Expanded(
                child: Container(),
              ),
              Text(
                formattedDate,
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {},
    );
  }
}
