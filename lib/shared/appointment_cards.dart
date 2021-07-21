import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:doctors_diary/services/database.dart';



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
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount:widget.appointmentsToday.length,
      shrinkWrap: true,
      itemBuilder: (context,index){
        AppointmentToday today=widget.appointmentsToday[index];

        return Card(
          margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
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
                          today.time,
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
                       //_launchCaller() async {
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

  // Future<String?> fetchNextAppointment(String name) async {
  //   bool isOnce = false;
  //   String? _nextAppo = " ";
  //   String s=DateTime.now().toString().substring(0,11)+"00:00:00.000Z";
  //   print(s);
  //
  //   await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection("Appointments")
  //       .where('name',isEqualTo: name)
  //       .where('appoDate',isGreaterThanOrEqualTo:s).orderBy('appoDate').get().then((value) => {
  //     value.docs.forEach((element) {
  //       if(!isOnce){
  //         print(element.id);
  //         isOnce = true;
  //         _nextAppo= element.data()['appoDate'].toString();
  //       }
  //
  //     })
  //
  //   });
  //
  //   return _nextAppo;
  // }

  Future setNextAppointment(String name, String patDoc) async{
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

}