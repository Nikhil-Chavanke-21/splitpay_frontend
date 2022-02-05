import 'package:flutter/foundation.dart';
import 'package:splitpay/views/qr_code.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IconButton(
          icon: Icon(Icons.qr_code_2),
          iconSize: 40.0,
          onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const QRViewExample(),
            ));
          },
        ),
      ),
    );
  }
}

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class Home extends StatefulWidget {
//   const Home({ Key? key }) : super(key: key);

//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   final _auth=FirebaseAuth.instance;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(child: Text('Home Screen')),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           String token=await _auth.currentUser!.getIdToken();
//           // await _auth.signOut();
//           // Navigator.pop(context);
//         },
//         child: Icon(Icons.logout),
//       ),
//     );
//   }
// }