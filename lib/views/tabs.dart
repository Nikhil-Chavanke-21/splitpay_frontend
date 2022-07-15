import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
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
      FontAwesomeIcons.chartBar,
      Icons.home,
      Icons.group,
      Icons.person,
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
      Profile(),
    ];

    return Scaffold(
      body: screens[_bottomNavIndex],
      bottomNavigationBar: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          systemNavigationBarColor: Color(0xff373A36),
        ),
        child: AnimatedBottomNavigationBar.builder(
          itemCount: iconList.length,
          tabBuilder: (int index, bool isActive) {
            final color = isActive
                ? Theme.of(context).primaryColor
                : Theme.of(context).accentColor;
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  iconList[index],
                  size: 24,
                  color: color,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    texts[index],
                    maxLines: 1,
                    style: TextStyle(color: color),
                  ),
                )
              ],
            );
          },
          backgroundColor: Color(0xff373A36),
          activeIndex: _bottomNavIndex,
          splashColor: Theme.of(context).colorScheme.primary,
          splashSpeedInMilliseconds: 300,
          notchSmoothness: NotchSmoothness.defaultEdge,
          gapLocation: GapLocation.center,
          onTap: (index) => setState(() => _bottomNavIndex = index),
          shadow: BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 12,
            spreadRadius: 0.5,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
