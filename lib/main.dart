
import 'package:doctors_diary/screens/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:splashscreen/splashscreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
      body: Container(
        child: SplashScreen(
          seconds: 4,
          imageBackground: AssetImage('assets/images/Android - 1spalshscreen_figma.png'),
          loaderColor: Colors.blue[300],
          //navigateAfterSeconds: AboutPage(),
          navigateAfterSeconds: Wrapper(),
        ),
        ),
      )
    );
  }
}
