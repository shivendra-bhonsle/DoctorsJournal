import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctors_diary/navigationBar/pages/Contacts/patient_list_page.dart';
import 'package:doctors_diary/screens/authenticate/loginScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:doctors_diary/shared/appointment_cards.dart';
import 'package:doctors_diary/navigationBar/menu_bar.dart';
import 'package:doctors_diary/services/database.dart';



class HomeTemp extends StatefulWidget {
  @override
  _HomeTempState createState() => _HomeTempState();
}

class _HomeTempState extends State<HomeTemp> {
  final _auth=FirebaseAuth.instance;
  List<AppointmentToday> appointmentToday=[];
  bool isDataLoaded=false;
  bool isListEmpty=false;

  Future fetchAppointmentsToday() async {
    String s=DateTime.now().toString().substring(0,11)+"00:00:00.000Z";
    print(s);
    try{
      await FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid).collection("Appointments").where('appoDate',isEqualTo:s).get().then((value) => {
        value.docs.forEach((element) {
          print(element.id);
          setState(() {
            appointmentToday.add(AppointmentToday(name: element.get('name'), time: element.get('appoTime'), mobile: element.get('mobile')));

          });

        })
      });

    }
    catch(e){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("#20 Unable to perform operation. Please check your connection")));
    }



  }


  late Future _fetch;
  @override
  void initState() {
    appointmentToday=[];
    super.initState();
    _fetch=fetchAppointmentsToday();
    DatabaseService(uid: _auth.currentUser!.uid).toDeletePastAppointments();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      drawer: MenuBar(),
      appBar: AppBar(
        title: Text("Appointments Today",style: TextStyle(fontFamily: 'Raleway', ),),

        centerTitle: true,
        backgroundColor: Colors.blue[900],
        actions: <Widget>[
          // Container(
          //
          //   padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
          //   child: ElevatedButton(onPressed:
          //             () async {
          //               await _auth.signOut();
          //               //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
          //               Navigator.pushReplacement(context,
          //                 MaterialPageRoute(
          //                     builder: (BuildContext context) => LoginScreen()),);
          //
          //       },
          //
          //    child:
          //        Text("Logout",style: TextStyle(fontWeight: FontWeight.bold)),
          //
          //     style: ElevatedButton.styleFrom(primary: Colors.red[900],padding: EdgeInsets.all(10)),
          //   ),
          // ),
          IconButton(onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => PatientList()));
          }, icon: Icon(Icons.person_add),padding:EdgeInsets.only(right: 10),iconSize: 30,)



        ],
      ),
      body:
      FutureBuilder(future: _fetch,
      builder: (context,snapshot){
        if(snapshot.connectionState==ConnectionState.waiting){
          return Center(
            child: CircularProgressIndicator(),
          );

        }else
          {
            if(snapshot.hasError){
              final snackBar = SnackBar(
                  content: Text('Could not fetch data'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
            return appointmentToday.isEmpty?
            Center(
                  child:Text("No Appointments Today"),
        )
                :Appointment(appointmentsToday: appointmentToday);
          }

      },),

    );
  }



}
