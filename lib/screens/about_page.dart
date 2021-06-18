import 'dart:ui';

import 'package:doctors_diary/screens/authenticate/loginScreen.dart';

import 'package:flutter/material.dart';
import 'package:swipe_up/swipe_up.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return SwipeUp(
      color: Colors.black,
      sensitivity: 0.5,
      onSwipe: (){
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));   //swipe up navigate to
      },
      child: Material(
        color: Colors.transparent,
        child: Text('Swipe up', style: TextStyle(color: Colors.black, fontSize: 15))
      ),
      body: Scaffold(                                       //design of about page
        appBar: AppBar(
          title: Text("Doctor's Diary",
          style: TextStyle(
            fontFamily: 'SweedScript',
              fontSize: 30
          ),
          ),
          backgroundColor: Colors.indigo[900],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
          child: Center(
            child: Column(
              children: [
                Text('About',
                style: TextStyle(
                  fontSize: 34,
                  fontFamily: 'Raleway',
                  //fontWeight: FontWeight.bold

                ),),
                SizedBox(height: 20,),
                Text(" 'Doctor's Diary' is an app particularly for doctors to manage there patients on there own without the help of any receptionist.",
                    style: TextStyle(
                  fontSize: 20,
                    fontFamily: 'Raleway-Light',
                    //fontStyle: FontStyle.italic,
                  letterSpacing: 0.9,
                  wordSpacing: 1.5
                ),
                textAlign: TextAlign.center,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
