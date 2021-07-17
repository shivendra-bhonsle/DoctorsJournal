import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctors_diary/navigationBar/pages/Calendar/Calender_page.dart';
import 'package:doctors_diary/navigationBar/pages/Contacts/ContactDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';



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
                      flex: 5,
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
}