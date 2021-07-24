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
          title: Text("Doctor's Journal",
          style: TextStyle(fontFamily: 'SweedScript', fontSize: 30.0,),
          ),
          backgroundColor: Colors.blue[900],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
          child: Center(
            child: Column(
              children: [
                Text('About the App',
                style: TextStyle(
                  fontSize: 34,
                  fontFamily: 'Raleway',
                  //fontWeight: FontWeight.bold

                ),),
                SizedBox(height: 20,),
                Text(" 'Doctor's Journal' is an Android App particularly for doctors and medical practitioners to manage their patients. Ideally, the app is for doctors to make it easy for them to operate their clinics without a receptionist but the receptionists can also use this application to manage the appointments and make their work paper-less. \n\nWe hope you have a great experience with our app! \n\nAny suggestions and improvements are most welcomed!",

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
