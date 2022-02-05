// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:splitpay/home.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: Home(),
//   ));
// }

// import 'package:flutter/material.dart';
// import 'package:pin_input_text_field/pin_input_text_field.dart';
// import 'package:sms_autofill/sms_autofill.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData.light(),
//       home: HomePage(),
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   String _code="";
//   String signature = "{{ app signature }}";

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     SmsAutoFill().unregisterListener();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData.light(),
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Plugin example app'),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.max,
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: <Widget>[
//               PhoneFieldHint(
//                 controller: phone,
//               ),
//               Spacer(),
//               PinFieldAutoFill(
//                 decoration: UnderlineDecoration(
//                   textStyle: TextStyle(fontSize: 20, color: Colors.black),
//                   colorBuilder: FixedColorBuilder(Colors.black.withOpacity(0.3)),
//                 ),
//                 currentCode: _code,
//                 onCodeSubmitted: (code) {},
//                 onCodeChanged: (code) {
//                   if (code!.length == 6) {
//                     FocusScope.of(context).requestFocus(FocusNode());
//                   }
//                 },
//               ),
//               Spacer(),
//               TextFieldPinAutoFill(
//                 currentCode: _code,
//               ),
//               Spacer(),
//               ElevatedButton(
//                 child: Text('Listen for sms code'),
//                 onPressed: () async {
//                   await SmsAutoFill().listenForCode;
//                 },
//               ),
//               ElevatedButton(
//                 child: Text('Set code to 123456'),
//                 onPressed: () async {
//                   setState(() {
//                     _code = '123456';
//                   });
//                 },
//               ),
//               SizedBox(height: 8.0),
//               Divider(height: 1.0),
//               SizedBox(height: 4.0),
//               Text("App Signature : $signature"),
//               SizedBox(height: 4.0),
//               ElevatedButton(
//                 child: Text('Get app signature'),
//                 onPressed: () async {
//                   signature = await SmsAutoFill().getAppSignature;
//                   setState(() {});
//                 },
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).push(MaterialPageRoute(builder: (_) => CodeAutoFillTestPage()));
//                 },
//                 child: Text("Test CodeAutoFill mixin"),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CodeAutoFillTestPage extends StatefulWidget {
//   @override
//   _CodeAutoFillTestPageState createState() => _CodeAutoFillTestPageState();
// }

// class _CodeAutoFillTestPageState extends State<CodeAutoFillTestPage> with CodeAutoFill {
//   String? appSignature;
//   String? otpCode;

//   @override
//   void codeUpdated() {
//     setState(() {
//       otpCode = code!;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     listenForCode();

//     SmsAutoFill().getAppSignature.then((signature) {
//       setState(() {
//         appSignature = signature;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     cancel();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final textStyle = TextStyle(fontSize: 18);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Listening for code"),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
//             child: Text(
//               "This is the current app signature: $appSignature",
//             ),
//           ),
//           const Spacer(),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 32),
//             child: Builder(
//               builder: (_) {
//                 if (otpCode == null) {
//                   return Text("Listening for code...", style: textStyle);
//                 }
//                 return Text("Code Received: $otpCode", style: textStyle);
//               },
//             ),
//           ),
//           const Spacer(),
//         ],
//       ),
//     );
//   }
// }

// -----------------------------------------------------------------------------------------------

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:splitpay/views/login.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: LoginScreen(),
//   ));
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:splitpay/models/user.dart';
import 'package:splitpay/views/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:splitpay/services/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  const _initialData = null;
  runApp(StreamProvider<UserId>.value(
    value: AuthService().user,
    initialData: _initialData,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Wrapper(),
    ),
  ));
}
// -----------------------------------------------------------------------------------------------


// import 'package:fl5utter/material.dart';
// import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
// import 'package:fwfh_url_launcher/fwfh_url_launcher.dart';

// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'fwfh_url_launcher',
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('UrlLauncherFactory Demo'),
//         ),
//         body: Center(
//           child: HtmlWidget(
//             '<a href="upi://pay?pa=9422252553@postbank&pn=RANGNATH%20SANTU%20CHAVANKE&cu=INR&mode=02&orgId=159768&sign=MEYCIQCG5OvaPjgIjSq7R1sLwVegnA9STIrtNCxFQZgMVpFzegIhAONzPBFLAOG2G7wh/fEuw9Tx+tWEnH+0nuEIeYdqNDK7&am=1">Launch URL</a>',
//             factoryBuilder: () => MyWidgetFactory(),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class MyWidgetFactory extends WidgetFactory with UrlLauncherFactory {}
// -----------------------------------------------------------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:intent/extra.dart';
// import 'package:intent/intent.dart' as android_intent;
// import 'package:intent/action.dart' as android_action;
// import 'dart:async' show StreamController;
// import 'dart:io';

// void main() => runApp(MyApp());

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   MyAppDataModel _myAppDataModel=MyAppDataModel();

//   @override
//   void initState() {
//     _myAppDataModel = MyAppDataModel();
//     _myAppDataModel.inputClickState.add([]);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Plugin Example App',
//             style: TextStyle(
//               color: Colors.black,
//             ),
//           ),
//           centerTitle: true,
//           backgroundColor: Colors.cyanAccent,
//         ),
//         body: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               StreamBuilder<List<String>>(
//                 initialData: [],
//                 stream: _myAppDataModel.outputResult,
//                 builder: (context, snapshot) => Padding(
//                   padding: EdgeInsets.only(
//                     left: 8,
//                     right: 8,
//                     top: 12,
//                     bottom: 24,
//                   ),
//                   child: snapshot.hasData
//                       ? snapshot.data!.isNotEmpty
//                           ? ClipRRect(
//                               borderRadius: BorderRadius.circular(24),
//                               child: Image.file(
//                                 File(snapshot.data![0]),
//                                 fit: BoxFit.cover,
//                                 width: MediaQuery.of(context).size.width * .75,
//                                 height:
//                                     MediaQuery.of(context).size.height * .35,
//                               ),
//                             )
//                           : Center()
//                       : CircularProgressIndicator(),
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: () => android_intent.Intent()
//                 ..setPackage("com.truecaller")
//                 ..setAction(android_action.Action.ACTION_VIEW)
//                 // ..setData(Uri(scheme: "https", host:"google.com"))
//                 ..setData(Uri(scheme: "tel", path: "123"))
//                 ..startActivity().catchError((e) => print(e)),
//                 child: Text('Intent'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class MyAppDataModel {
//   StreamController<List<String>> _streamController =
//       StreamController<List<String>>.broadcast();

//   Sink<List<String>> get inputClickState => _streamController;

//   Stream<List<String>> get outputResult =>
//       _streamController.stream.map((data) => data);

//   dispose() => _streamController.close();
// }