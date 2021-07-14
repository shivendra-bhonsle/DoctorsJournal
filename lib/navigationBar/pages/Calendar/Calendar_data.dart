import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:doctors_diary/services/database.dart';


class CalendarData extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: (){
      DatabaseService(uid: _auth.currentUser!.uid).fetchAllAppointments();
    },
    child: Text("Press"),
    );
  }
}
