
import 'package:doctors_diary/screens/about_page.dart';
import 'package:doctors_diary/screens/authenticate/loginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home/home_temp.dart';

//this class will tell where control will go to home screen or Authentication

/*class Wrapper extends StatefulWidget {
  //const Wrapper({Key? key}) : super(key: key);
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

  /*late FirebaseAuth _auth;

  late User _user;

  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _auth = FirebaseAuth.instance;
    _user = _auth.currentUser!;
    isLoading = false;
  }


  @override
  Widget build(BuildContext context) {
    return isLoading?Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    ):_user==null?Authenticate():HomeTemp();
  }*/


}
*/

final FirebaseAuth _auth = FirebaseAuth.instance;

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //return AboutPage();
    return _auth.currentUser==null? AboutPage():HomeTemp();
  }
}
