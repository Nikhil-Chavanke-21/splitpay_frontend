import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:splitpay/config.dart';
import 'package:http/http.dart' as http;
import 'package:splitpay/models/user.dart';
import 'package:splitpay/views/components/loading.dart';
import 'package:flutter_linear_datepicker/flutter_datepicker.dart';

class MonthStats extends StatefulWidget {
  const MonthStats({Key? key, this.uid}) : super(key: key);
  final uid;

  @override
  State<MonthStats> createState() => _MonthStatsState();
}

class _MonthStatsState extends State<MonthStats> {
  bool loading = true;
  List? expenses;
  Map ?stats;
  int _year = DateTime.now().year;
  int _month = DateTime.now().month;

  @override
  void initState() {
    _getExpenses();
    super.initState();
  }

  _getExpenses() async {
    Map<String, dynamic> query = {
      'year': _year.toString(),
      'month': _month.toString(),
    };
    var url = Uri.http(
        backend_url, '/v1/user/stats/monthly/' + widget.uid, query);
    Map response = json.decode((await http.get(url)).body);

    stats = response['stats'];
    expenses = response['expenses'];

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text('Monthly Expenses'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              LinearDatePicker(
                showLabels: false,
                endDate: DateFormat("yyyy/MM/dd")
                    .format(DateTime.now())
                    .toString(),
                dateChangeListener: (String selectedDate) {
                  List date = selectedDate.split('/');
                  _year = int.parse(date[0]);
                  _month = int.parse(date[1]);
                },
                selectedRowStyle: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                showMonthName: true,
                isJalaali: false,
                showDay: false,
              ),
              Divider(),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });

                  Map<String, dynamic> query = {
                    'year': _year.toString(),
                    'month': _month.toString(),
                  };
                  var url = Uri.http(
                      backend_url,
                      '/v1/user/stats/monthly/' + widget.uid,
                      query);
                  Map response = json.decode((await http.get(url)).body);

                  stats = response['stats'];
                  expenses = response['expenses'];

                  setState(() {
                    loading = false;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                                          Colors.deepPurpleAccent),
                ),
                child: Text('Fetch Expenses'),
              ),
            ],
          ),
          loading == true
          ? Loading()
          : expenses!.length==0
          ? SizedBox(height: 50)
          : Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List<Widget>.from(stats!.keys.map((entry) {
                return Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 25.0,
                        backgroundColor: Theme.of(context).cardColor,
                        child: Icon(
                          categoryIcon[entry],
                          color: categoryColor[entry],
                        ),
                      ),
                      Text(
                        '₹ '+stats![entry].toString(),
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              })),
            ),
          ),
          Text(
            'Expenses',
            style: TextStyle(
              fontSize: 25,
            ),
          ),
          loading == true
          ? Loading()
          : expenses!.length==0
          ? Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              children: [
                Icon(
                  Icons.list,
                  size: 60,
                  color: Colors.blueGrey[200],
                ),
                Text(
                  'No Expenses',
                  style: TextStyle(
                    color: Colors.blueGrey[200],
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
          : Expanded(
            child: ListView(
              children: List<Widget>.from(expenses!.map((entry) {
                DateTime time = DateTime.fromMillisecondsSinceEpoch(
                    entry['time'] * 1000);
                String formattedDate = time.year != DateTime.now().year
                    ? time.year.toString()
                    : time.month != DateTime.now().month ||
                            time.day != DateTime.now().day
                        ? DateFormat("dd/MM").format(time).toString()
                        : DateFormat("h:mm a")
                            .format(time)
                            .toString()
                            .toLowerCase();
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    tileColor: Theme.of(context).cardColor,
                    title: Text(entry['description']),
                    subtitle: Text(entry['payeeUpi']),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).cardColor,
                      child: Icon(
                        categoryIcon[entry['category']],
                        color: categoryColor[entry['category']],
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(formattedDate),
                        Text(
                          '₹ ' + entry['amount'].toString(),
                          style: TextStyle(fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                );
              })),
            ),
          ),
        ],
      ),
    );
  }
}
