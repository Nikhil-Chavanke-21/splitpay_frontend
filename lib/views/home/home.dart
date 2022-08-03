import 'package:flutter/foundation.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:splitpay/views/home/add_manually.dart';
import 'package:splitpay/views/home/pay_upi.dart';
import 'package:splitpay/views/home/qr_code.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeumorphicAppBar(
        title: Text('Home'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>QRViewExample()));
                },
                child: Neumorphic(
                  child: Container(
                    height: 100,
                    width: 90,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.qr_code_2,
                            size: 40.0,
                            color: Colors.cyanAccent,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Scan QR',
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PayUPI()));
                },
                child: Neumorphic(
                  child: Container(
                    height: 100,
                    width: 90,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.alternate_email,
                            size: 40.0,
                            color: Colors.cyanAccent,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Pay UPI',
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddManually()));
                },
                child: Neumorphic(
                  child: Container(
                    height: 100,
                    width: 90,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.add_box_outlined,
                            size: 40.0,
                            color: Colors.cyanAccent,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Add Man.',
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
