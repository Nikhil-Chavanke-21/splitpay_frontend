import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:splitpay/models/user.dart';
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
      appBar: NeumorphicAppBar(
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Group Expenses',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SvgPicture.asset(
                          'assets/images/group.svg',
                          height: 60,
                          width: 60,
                        ),
                      ],
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SvgPicture.asset(
                          'assets/images/month.svg',
                          height: 50,
                          width: 50,
                        ),
                        Text(
                          'Monthly Statistics',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Pending Dues',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SvgPicture.asset(
                          'assets/images/dues.svg',
                          height: 60,
                          width: 60,
                        ),
                      ],
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