import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctors_diary/models/patient.dart';
import 'package:doctors_diary/screens/authenticate/loginScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:doctors_diary/screens/wrapper.dart';
import 'package:doctors_diary/shared/appointment_cards.dart';
import 'package:doctors_diary/navigationBar/menu_bar.dart';
import 'package:doctors_diary/services/database.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Widget appointments(){
  return Appointment();
}

class HomeTemp extends StatefulWidget {
  @override
  _HomeTempState createState() => _HomeTempState();
}

class _HomeTempState extends State<HomeTemp> {
  final _auth=FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuBar(),
      appBar: AppBar(
        title: Text("Appointments Today"),
        centerTitle: true,
        backgroundColor: Colors.indigo[900],
        actions: <Widget>[
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.person_add),
          ),
        ],
      ),
      body: Column(
        children: [
          appointments()
        ],

      ),

      floatingActionButton: FloatingActionButton(
        child:Icon(Icons.logout),
        onPressed: () async{
          await _auth.signOut();
          //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
          Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (BuildContext context) => LoginScreen()),);

        },
      ),
    );
  }
}
