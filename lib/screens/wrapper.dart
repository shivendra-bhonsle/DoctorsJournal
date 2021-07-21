
import 'package:doctors_diary/screens/about_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home/home_temp.dart';

//this class will tell where control will go to home screen or Authentication



final FirebaseAuth _auth = FirebaseAuth.instance;

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _auth.currentUser==null? AboutPage():HomeTemp();
  }
}
