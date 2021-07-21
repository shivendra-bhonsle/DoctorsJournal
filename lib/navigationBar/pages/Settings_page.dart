import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctors_diary/navigationBar/pages/profile_page.dart';
import 'package:doctors_diary/screens/authenticate/loginScreen.dart';
import 'package:doctors_diary/screens/home/home_temp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;



class SettingsPage extends StatefulWidget {
  scheduleNotification(String name, String time, tz.Location local) => createState().showNotificationCard(name, time, local);
  cancelScheduledNotification(String s) => createState().cancelSingleNotification(s);
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}
final FirebaseAuth _auth = FirebaseAuth.instance;
final List<bool> isSelected = [false, true];

class _SettingsPageState extends State<SettingsPage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static int notiTime = 30;
  final List<int> list_items = <int>[5, 10, 30, 60];


  @override
  void initState() {
    super.initState();
    var androidInitialize = new AndroidInitializationSettings("diary");
    var iOSInitialize = new IOSInitializationSettings();
    final initializationsSettings = new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(
      initializationsSettings,
    );
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation("America/Detroit"));
  }

  void showNotificationCard(String name, String time, tz.Location local){
    String s = time;
    TimeOfDay _startTime = TimeOfDay(hour:int.parse(s.split(":")[0]),minute: int.parse(s.split(":")[1]));
    print(_startTime);
    showNotification(name, DateTime.now(), _startTime, local);
  }

  DateTime convert(DateTime day, TimeOfDay time){
    return new DateTime(day.year, day.month, day.day, time.hour, time.minute, 0);
  }

  Future showNotification(String name,DateTime day, TimeOfDay time, tz.Location local) async{
    var androidDetails = new AndroidNotificationDetails(
      "channelId",
      "channelName",
      "channelDescription",
      importance: Importance.high,
    );
    DateTime appointmentTime = convert(DateTime.now(), time);
    String channelID = //appointmentTime.toString().substring(0,4)+
        appointmentTime.toString().substring(6,7)+
        appointmentTime.toString().substring(8,10)+
        appointmentTime.toString().substring(11,13)+
        appointmentTime.toString().substring(14,16)+
        appointmentTime.toString().substring(17,19);
    print("channelID =" + channelID );
    int notificationchannelID = int.parse(channelID);
    print(notificationchannelID);
    var generalNotificationDetails = new NotificationDetails(android: androidDetails,);
    TimeOfDay _currtime = TimeOfDay.now();
    double _currTime = _currtime.hour.toDouble() * 60 + (_currtime.minute.toDouble());
    double _notisched = time.hour.toDouble() * 60 + (time.minute.toDouble());
    if (_notisched - _currTime > notiTime) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationchannelID,
        name,
        "you have appointment at "+time.toString().substring(10,15),
        tz.TZDateTime.from(appointmentTime, local).subtract(Duration(minutes: notiTime)),
        generalNotificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future cancelSingleNotification(String s) async{
    TimeOfDay _startTime = TimeOfDay(hour:int.parse(s.split(":")[0]),minute: int.parse(s.split(":")[1]));
    DateTime appointmentTime = convert(DateTime.now(), _startTime);
    String channelID = //appointmentTime.toString().substring(0,4)+
    appointmentTime.toString().substring(6,7)+
        appointmentTime.toString().substring(8,10)+
        appointmentTime.toString().substring(11,13)+
        appointmentTime.toString().substring(14,16)+
        appointmentTime.toString().substring(17,19);
    int notificationchannelID = int.parse(channelID);
    await flutterLocalNotificationsPlugin.cancel(notificationchannelID);
  }

  Future cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: ()async{
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>HomeTemp()), (Route<dynamic> route) => false);
          return false;
          },
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
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("NOTIFICATIONS",
                          style: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w800,),
                        ),
                        SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Reminder before", style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w800,),),
                            DropdownButton(
                                value: notiTime,
                                items: list_items.map((int items) {
                                  return DropdownMenuItem(
                                    child: Text("$items minutes"),
                                  value: items,
                                  );
                                }).toList(),
                              onChanged: (int? value){
                                  cancelNotification();
                                  setState(() {
                                    notiTime = value!;
                                  });
                              },
                            ),
                          ],
                        ),
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
                                }
                                )
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
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

        ),
      ),
    );
  }

  Future deleteAccount(String uid) async {
    try{
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
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

    }
    catch(e){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("#15 Unable to perform operation. Please check your connection")));
    }


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
                  try{
                    await _auth.signOut().then((value) => deleteAccount(uid));

                  }
                  catch(e){
                    print(e);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("#16 Unable to perform operation. Please check your connection")));
                  }


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
