import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctors_diary/models/patient.dart';
import 'package:doctors_diary/navigationBar/pages/Contacts/patient_list_page.dart';
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
    //print(DateTime.now());
    String s=DateTime.now().toString().substring(0,11)+"00:00:00.000Z";
    print(s);

    await FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid).collection("Appointments").where('appoDate',isEqualTo:s).get().then((value) => {
      value.docs.forEach((element) {
        print(element.id);
        setState(() {
          appointmentToday.add(AppointmentToday(name: element.get('name'), time: element.get('appoTime'), mobile: element.get('mobile')));

        });

      })
    });


  }


  late Future _fetch;
  @override
  void initState() {
    // TODO: implement initState
    appointmentToday=[];
    super.initState();
    _fetch=fetchAppointmentsToday();
  }
  
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
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => PatientList()));
              },
              icon: Icon(Icons.person_add),
          ),
        ],
      ),
      body: FutureBuilder(future: _fetch,
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
