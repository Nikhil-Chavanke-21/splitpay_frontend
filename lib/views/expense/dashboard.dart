import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitpay/models/user.dart';
import 'package:splitpay/views/components/loading.dart';
import 'package:splitpay/views/expense/group_stats.dart';
import 'package:splitpay/views/expense/month_stats.dart';
// import 'package:flutter_linear_datepicker/flutter_datepicker.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({ Key? key }) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserId>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text('Expense'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 20.0, 0, 0),
              child: Card(
                child: InkWell(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupStats(uid: user.uid),
                    ));
                  },
                  child: Container(
                    width: 300,
                    height: 80,
                    child: Center(
                      child: Text(
                        'Group Expenses',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 20.0, 0, 0),
              child: Card(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MonthStats(uid: user.uid),
                        ));
                  },
                  child: Container(
                    width: 300,
                    height: 80,
                    child: Center(
                      child: Text(
                        'Monthly Expenses',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}