import 'dart:ui';
import 'package:flutter/material.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(                                       //design of about page
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
                Text('About the App',
                  style: TextStyle(
                    fontSize: 34,
                    fontFamily: 'Raleway',
                    //fontWeight: FontWeight.bold

                  ),),
                SizedBox(height: 20,),
                Text(" 'Doctor's Diary' is an Android App particularly for doctors and medical practitioners to manage their patients. Ideally, the app is for doctors to make it easy for them to operate their clinics without a receptionist but the receptionists can also use this application to manage the appointments and make their work paper-less. \n\nWe hope you have a great experience with our app! \n\nAny suggestions and improvements are most welcomed!",

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
      );
  }
}
