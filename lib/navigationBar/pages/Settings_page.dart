import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctors_diary/navigationBar/pages/Contacts/ContactDetails.dart';
import 'package:doctors_diary/navigationBar/pages/profile_page.dart';
import 'package:doctors_diary/screens/authenticate/loginScreen.dart';
import 'package:doctors_diary/screens/home/home_temp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}
final FirebaseAuth _auth = FirebaseAuth.instance;

class _SettingsState extends State<Settings> {



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.lightBlue[50],
        appBar: AppBar(
          title: Text('Settings'),
          centerTitle: true,
          backgroundColor: Colors.blue[600],
        ),
        body: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(12),
          child: Column(
            children: <Widget>[
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                ),
                child: Container(
                  width: 500,
                  height: 110,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("NOTIFICATIONS",
                        style: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w800,),
                      ),
                      SizedBox(height: 20,),
                      Row(
                        children: [
                          Text("Turn on/off notifications", style: GoogleFonts.roboto(fontSize: 18, fontStyle: FontStyle.italic,)),
                          //TODO toggle button add
                        ],
                      )
                    ],
                  ),
                ),

              ),

              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                ),
                child: Container(
                  width: 500,
                  height: 180,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ACCOUNT",
                        style: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w800,),
                      ),
                      SizedBox(height: 4,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Delete Account", style: GoogleFonts.roboto(fontSize: 18,  fontStyle: FontStyle.italic,)),
                          //SizedBox(width: 130,),
                          //Text("|", style: GoogleFonts.roboto(fontSize: 40, fontWeight: FontWeight.w200)),
                          //SizedBox(width: 10,),
                          IconButton(
                              icon: Icon(Icons.delete),
                              splashRadius: 25,
                              splashColor: Colors.red[200],
                              onPressed: ()  async{
                                await createAlertDialogForDeleteAccount(context);



                              })
                        ],
                      ),

                      Divider(thickness: 1, height: 20, color: Colors.black,),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            autofocus: false,
                            clipBehavior: Clip.none,

                            onPressed: (){
                              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Profile()));
                            },
                            child: Text("Go to Profile"),

                          ),
                        ),
                      )
                    ],
                  ),
                ),

              )
            ],
          ),
        ),

      ),
    );
  }

  Future deleteAccount(String uid) async {

    String deleteDoc="";//for id to doc to be deleted
    await FirebaseFirestore.instance.collection('users').doc(
        uid).collection("Appointments").get().then((
        QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) {
        deleteDoc = element.id.toString(); //get the id of the doc by searching by time and name
        FirebaseFirestore.instance.collection('users').doc(uid).collection("Appointments").doc(deleteDoc).delete();

      });
    });
    deleteDoc="";
    //await FirebaseFirestore.instance.collection('users').doc(uid).delete();
    await FirebaseFirestore.instance.collection('users').doc(
        uid).collection("PatientList").get().then((
        QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((element) {
        deleteDoc = element.id.toString(); //get the id of the doc by searching by time and name
        FirebaseFirestore.instance.collection('users').doc(uid).collection("PatientList").doc(deleteDoc).delete();

      });
    });
    await FirebaseFirestore.instance.collection('users').doc(
        uid).delete();





  }

  Future createAlertDialogForDeleteAccount(BuildContext context) async {

    showDialog(context: context, builder: (context) {
        return AlertDialog(
        title: Text("Are you sure you want to delete your account?"),
        actions: [
          MaterialButton(
              elevation: 5.0,
              child: Text('Delete', style: TextStyle(color: Colors.red),),
              onPressed: () async {
                try{
                  String uid = _auth.currentUser!.uid;
                  //await _auth.signOut().then((value) => {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Deleting Account"),
                  ));
                  await _auth.signOut().then((value) => deleteAccount(uid));


                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                      LoginScreen()), (Route<dynamic> route) => false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Account Deleted"),
                  ));

                }
                catch(e){
                  print(e.toString());
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Could Not delete Account. Please try again"),
                  ));
                }

              }
          ),
          MaterialButton(
              elevation: 5.0,
              child: Text('Cancel', style: TextStyle(color: Colors.blue),),
              onPressed: () {
                Navigator.of(context).pop();

              }
          )
        ],
      );

    });

  }


}
