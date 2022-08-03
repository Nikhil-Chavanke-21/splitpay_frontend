import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:splitpay/models/user.dart';
import 'package:splitpay/views/theme_provider.dart';
import 'package:splitpay/views/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:splitpay/services/auth.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

void main() async {
  // initialize firebase app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // set potrait orientation
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  const _initialData = null;

  // run app
  runApp(StreamProvider<UserId>.value(
    value: AuthService().user,
    initialData: _initialData,
    child: ChangeNotifierProvider(
      create: (context)=> ThemeProvider(),
      builder: (context, _){
        final themeProvider= Provider.of<ThemeProvider>(context);

        return NeumorphicApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          themeMode: themeProvider.themeMode,
          theme: NeumorphicThemeData(
            baseColor: Color(0xFFFFFFFF),
            lightSource: LightSource.topLeft,
            depth: 3,
            intensity: 1,
          ),
          darkTheme: NeumorphicThemeData(
            baseColor: Color(0xFF28282a),
            lightSource: LightSource.topLeft,
            accentColor: Colors.cyanAccent,
            depth: 3,
            intensity: 0.5,
          ),
          home: Wrapper(),
        );
      },
    ),
  ));
}
