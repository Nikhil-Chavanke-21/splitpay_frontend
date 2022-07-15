import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:splitpay/config.dart';
import 'package:splitpay/views/components/loading.dart';
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

  @override
  Widget build(BuildContext context) {
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
      body: loading == true
          ? Loading()
          : Container(
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
                              logs![index]['amount'].toDouble(),
                              logs![index]['isMine'],
                              logs![index]['expense'].toDouble(),
                              DateTime.fromMillisecondsSinceEpoch(
                                  logs![index]['time'] * 1000),
                            );
                          }
                        }),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    color: Theme.of(context).backgroundColor,
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
      double amount, bool isMine, double expense, DateTime time) {
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
        // alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
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
                  isMine ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown,
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
              Text(formattedDate),
            ],
          ),
        ),
      ),
      onTap: () {},
    );
  }
}
