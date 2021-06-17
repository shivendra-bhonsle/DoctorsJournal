import 'package:doctors_diary/screens/about_page.dart';
import 'package:doctors_diary/screens/tempWrapper.dart';
//import 'package:doctors_diary/shared/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

void main() {
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
          imageBackground: AssetImage('images/Android - 1spalshscreen_figma.png'),
          loaderColor: Colors.blue[300],
          navigateAfterSeconds: AboutPage(),
        ),
        ),
      )
    );
  }
}
