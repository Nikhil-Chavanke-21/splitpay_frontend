import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:splitpay/models/user.dart';
import 'package:splitpay/views/expense/dashboard.dart';
import 'package:splitpay/views/home/home.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:splitpay/views/ledger/groups.dart';
import 'package:splitpay/views/profile/profile.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

class Tabs extends StatefulWidget {
  @override
  _TabsState createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  late Animation<double> fabAnimation;

  var _bottomNavIndex=1;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserId>(context);

    final iconList = <IconData>[
      FontAwesomeIcons.solidChartBar,
      Icons.home,
      Icons.group,
      Icons.person,
    ];

    final iconListOutlined = <IconData>[
      FontAwesomeIcons.chartBar,
      Icons.home_outlined,
      Icons.group_outlined,
      Icons.person_outline,
    ];

    var texts = [
      'Stats',
      'Home',
      'Groups',
      'Profile',
    ];
    var screens = [
      Dashboard(),
      Home(),
      Groups(uid: user.uid),
      Profile(uid: user.uid, photoURL: user.photoURL, name: user.name),
    ];

    return Scaffold(
      body: screens[_bottomNavIndex],
      bottomNavigationBar: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          systemNavigationBarColor: Colors.white,
        ),
        child: AnimatedBottomNavigationBar.builder(
          itemCount: iconList.length,
          tabBuilder: (int index, bool isActive) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isActive?iconList[index]:iconListOutlined[index],
                  size: isActive?28:24,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    texts[index],
                    maxLines: 1,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                )
              ],
            );
          },
          backgroundColor: Colors.white,
          activeIndex: _bottomNavIndex,
          splashColor: Theme.of(context).primaryColor,
          splashSpeedInMilliseconds: 300,
          notchSmoothness: NotchSmoothness.defaultEdge,
          gapLocation: GapLocation.center,
          onTap: (index) => setState(() => _bottomNavIndex = index),
          shadow: BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 12,
            spreadRadius: 0.5,
          ),
        ),
      ),
    );
  }
}
