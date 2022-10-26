import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:splitpay/services/auth.dart';
import 'package:splitpay/views/components/loading.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  bool loading = false;
  int _current = 0;
  List list = [0, 1, 2];

  getItem(String image, String title, String description, double size) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        systemNavigationBarColor: Color(0xff373A36),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image(
                  image: AssetImage('assets/images/splitpay.png'),
                  width: 50,
                  height: 50,
                ),
                Text(
                  'SplitPay',
                  style: TextStyle(
                    fontSize: 35.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 260,
            child: Center(
              child: Image(
                image: AssetImage(image),
                height: size,
                width: size,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
              child: Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                  fontSize: 35.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  height: 50.0,
                ),
                CarouselSlider(
                  options: CarouselOptions(
                      autoPlay: true,
                      height: 460.0,
                      viewportFraction: 1.0,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      }),
                  items: [
                    getItem('assets/images/bills.png', 'Split Bills',
                        'Easily split your payment, No manual entry needed to track dues', 200),
                    getItem('assets/images/handshake.png', 'Settle dues',
                        'Settle dues with your friends in just one click, with payment app of you choice', 200),
                    getItem('assets/images/track.png', 'Track Expenses',
                        'Track your expenses with no efforts, and get all involved statistics', 220),
                  ],
                ),
                Container(
                  margin: EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: list.map((index) {
                      return _current == index
                          ? Container(
                              width: 24.0,
                              height: 8.0,
                              margin: EdgeInsets.symmetric(horizontal: 2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0)),
                                color: Colors.white,
                              ),
                            )
                          : Container(
                              width: 8.0,
                              height: 8.0,
                              margin: EdgeInsets.symmetric(horizontal: 2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            );
                    }).toList(),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 250.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0)),
                  ),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(25.0),
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                              fontSize: 26.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        width: 170.0,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Theme.of(context).canvasColor),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28.0),
                                      side: BorderSide(color: Colors.white)))),
                          onPressed: () async {
                            setState(() {
                              loading = true;
                            });
                            dynamic result = await _auth.signInWithGoogle();
                            if (result == null) {
                              setState(() {
                                loading = false;
                                Fluttertoast.showToast(
                                    msg: 'Invalid Email',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.black87,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              });
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'Sign In with',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Image.asset(
                                  "assets/images/google.png",
                                  width: 25,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Text('By registering you agree with our companies'),
                      // InkWell(
                      //   child: Text('Terms & Conditions',
                      //       style: TextStyle(color: Colors.blue)),
                      //   onTap: () async {
                      //     String url =
                      //         'https://docs.flutter.io/flutter/services/UrlLauncher-class.html';
                      //     if (await canLaunch(url)) {
                      //       await launch(url);
                      //     } else {
                      //       throw 'Could not launch $url';
                      //     }
                      //   },
                      // ),
                      Text('Terms & Conditions'),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
