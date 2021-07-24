import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctors_diary/navigationBar/pages/Settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:doctors_diary/services/database.dart';
import 'package:intl/intl.dart';




class AppointmentToday{
  String name;
  String mobile;
  String time;

  AppointmentToday({required this.name,required this.mobile,required this.time});
}
class Appointment extends StatefulWidget {
  @override
  _AppointmentState createState() => _AppointmentState();
  List<AppointmentToday> appointmentsToday;
  Appointment({Key? key,required this.appointmentsToday}): super(key: key);
}

class _AppointmentState extends State<Appointment> {

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation("Asia/Kolkata"));
  }
  DateTime convertFormat(String time24){
    DateTime dt=DateTime.now();
    String time=dt.toString().substring(0,10)+" "+time24;
    dt=DateTime.parse(time);
    return dt;

  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount:widget.appointmentsToday.length,
      shrinkWrap: true,
      itemBuilder: (context,index){
        AppointmentToday today=widget.appointmentsToday[index];
        SettingsPage().scheduleNotification(today.name, today.time, tz.local);


        return Card(
          color: Colors.white,
          margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      today.name,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                        ),
                        Text(
                          DateFormat("h:mma").format(convertFormat(today.time)),
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20.0,),
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                    ),
                    TextButton(
                      onPressed: () async{

                          String mob=today.mobile.toString();
                          final url = "tel:"+mob;
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        //}

                      },
                      child: Text(
                        today.mobile,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                        ),
                      ),
                      ),

                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                        child: ElevatedButton(
                          onPressed: ()async{
                            try{
                              String deleteDoc="";//for id to doc to be deleted
                              await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection("Appointments").
                              where('name', isEqualTo:today.name).where('appoTime',isEqualTo: today.time).get().then((querySnapshot) => {
                                querySnapshot.docs.forEach((DocumentSnapshot element) {
                                  deleteDoc = element.id.toString(); //get the id of the doc by searching by time and name
                                  //print(patientId);
                                })
                              });

                              //delete the doc by passing its id
                              await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection("Appointments").doc(deleteDoc).delete();
                              setState(() {
                                widget.appointmentsToday.removeWhere((element) => element.name==today.name && element.time==today.time);

                              });


                              String patDoc="";//for id to doc of Patient
                              await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection("PatientList").
                              where('name', isEqualTo:today.name).where('phoneno',isEqualTo: today.mobile).get().then((querySnapshot) => {
                                querySnapshot.docs.forEach((DocumentSnapshot element) {
                                  patDoc = element.id.toString(); //get the id of the doc by searching by time and name
                                  //print(patientId);
                                })
                              });

                              //fetching completed appointment i.e. nextAppo from database
                              String nextAppo_fetched = " ";
                              await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                                  .getPatientNextAppo(patDoc)
                                  .then((value) => {
                                nextAppo_fetched = value.toString()
                              });

                              //setting lastAppo to nextAppo
                              await FirebaseFirestore.instance.collection('users').doc(
                                  FirebaseAuth.instance.currentUser!.uid).
                              collection('PatientList').doc(patDoc).set(
                                  {'lastAppo': nextAppo_fetched},
                                  SetOptions(merge: true));

                              //fetch and set nextAppo to coming appointment
                              await setNextAppointment(today.name, patDoc);
                              SettingsPage().cancelScheduledNotification(today.time);

                            }
                            catch(e){
                              print(e);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text("#12 Unable to perform operation. Please check your connection")));
                            }



                          },
                          child: Text('Done'),
                            style: ElevatedButton.styleFrom(
                                primary: Colors.green,
                        )
                        ),
                    ),

                    Expanded(
                      flex: 3,
                      child: SizedBox(width: 10.0,),
                    ),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(onPressed: () async {
                        try{
                          String deleteDoc="";//for id to doc to be deleted
                          await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection("Appointments").
                          where('name', isEqualTo:today.name).where('appoTime',isEqualTo: today.time).get().then((querySnapshot) => {
                            querySnapshot.docs.forEach((DocumentSnapshot element) {
                              deleteDoc = element.id.toString(); //get the id of the doc by searching by time and name
                              //print(patientId);
                            })
                          });

                          //delete the doc by passing its id
                          await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection("Appointments").doc(deleteDoc).delete();
                          setState(() {
                            widget.appointmentsToday.removeWhere((element) => element.name==today.name && element.time==today.time);

                          });


                          String patDoc="";//for id to doc of Patient
                          await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection("PatientList").
                          where('name', isEqualTo:today.name).where('phoneno',isEqualTo: today.mobile).get().then((querySnapshot) => {
                            querySnapshot.docs.forEach((DocumentSnapshot element) {
                              patDoc = element.id.toString(); //get the id of the doc by searching by time and name
                              //print(patientId);
                            })
                          });


                          //to fetch and set nextAppo to earliest coming appointment
                          await setNextAppointment(today.name, patDoc);
                          SettingsPage().cancelScheduledNotification(today.time);

                        }
                        catch(e){
                          print(e);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("#13 Unable to perform operation. Please check your connection")));
                        }


                      } ,
                        child: Text(
                            'Cancel'
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },

    );
  }


  Future setNextAppointment(String name, String patDoc) async{
    try{
    //to set nextAppo in "Patientlist->patient doc" to 'not assigned'
    String nextAppoStatus = "";
    DateTime minDt = DateTime.parse("2100-01-01 00:00:00Z");
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection("Appointments")
        .where('name',isEqualTo: name)
        .get().then((value) => {
    value.docs.forEach((element) async {
    DateTime Dt = DateTime.parse(element.data()['appoDate']);
    if(Dt.isBefore(minDt)){
    minDt = Dt;
    }
    }),
    //print(_nextAppo),
    print("before setting nextAppo"),

    if(minDt == DateTime.parse("2100-01-01 00:00:00Z")){
    nextAppoStatus = "Not Assigned"
    }else{
    nextAppoStatus = minDt.toString()
    }

    }).then((value) async {
    await FirebaseFirestore.instance.collection('users').doc(
    FirebaseAuth.instance.currentUser!.uid).
    collection('PatientList').doc(patDoc).set(
    {'nextAppo': nextAppoStatus},
    SetOptions(merge: true));
    });

    }
    catch(e){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("#14 Unable to perform operation. Please check your connection")));
    }

  }

}