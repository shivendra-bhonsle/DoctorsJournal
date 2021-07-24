import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctors_diary/screens/home/home_temp.dart';
import 'package:doctors_diary/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';


//Event Class
class Event {
  final String title;
  final TimeOfDay time;
  Event({required this.title, required this.time});
  String toString() => this.title;
}

class CalendarPage extends StatelessWidget {
  final String name,mobile,patID;
  final bool isFromContactDetails;
  const CalendarPage({Key? key, this.name="not assigned", this.mobile="not assigned",this.isFromContactDetails=false, this.patID="not assigned"}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:()async{ Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>HomeTemp()), (Route<dynamic> route) => false);
      return false;},

      child: Scaffold(
        appBar: AppBar(
          title: Text('Calender',style: TextStyle(fontFamily: 'Raleway', fontSize: 25.0,),),

          centerTitle: true,
          backgroundColor: Colors.blue[900],

        ),
        body: Calendar(name: name,mobile: mobile,isFromContactDetails:isFromContactDetails, patID: patID),
      ),
    );
  }
}

class Calendar extends StatefulWidget {
  final String name,mobile, patID;
  final bool isFromContactDetails;
  const Calendar({Key? key,required this.name,required this.mobile,required this.isFromContactDetails, required this.patID}) : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  //Initialising Variables
  TimeOfDay _time = TimeOfDay.now();
  late TimeOfDay picked;
  Map<DateTime?, List<Event>> selectedEvents = {};
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  bool isDateSelected=false;
  final currentDay = DateTime.now();
  TextEditingController _eventController = TextEditingController();

  //database variables
  FirebaseAuth _auth = FirebaseAuth.instance;


  //To select the time of appointment
  Future<Null> selectTime(BuildContext context) async {
    await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );},
    ).then((value) => {
      setState((){
        picked = value!;
      }),
    });
  }

  Future fetchAllAppointments() async {
    try{
      //fetch all docs in appointment section
      await FirebaseFirestore.instance.collection('users').doc(
          _auth.currentUser!.uid).collection("Appointments").get().then((
          QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((element) {
          //for each doc grab the date and time and convert it to DateTime and TimeOfDay resp from string
          String s=element.get('appoTime');
          DateTime dt=DateTime.parse(element.get('appoDate'));
          TimeOfDay _startTime = TimeOfDay(hour:int.parse(s.split(":")[0]),minute: int.parse(s.split(":")[1]));

          //add those date in selectedEvents array and pass the name and time as Event list inside it
          if(selectedEvents[dt]!=null){
            setState(() {
              selectedEvents[dt]!.add(Event(
                title: element.get('name'),
                time: _startTime,
              ));
            });

          }else{
            setState(() {
              selectedEvents[dt] = [
                Event(
                  title: element.get('name'),
                  time: _startTime,
                )
              ];
            });

          }


        });
      });

    }
    catch(e){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("#6 Unable to perform operation. Please check your connection")));
    }


  }

  late Future _future;
  @override
  void initState(){
    selectedEvents = {};
    super.initState();
    _future=fetchAllAppointments();

  }

  //Get events
  List<Event> getEventsfromDay(DateTime date){
    return selectedEvents[date] ?? [];
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  //Select day
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    /*print("Selected day para "+selectedDay.toString());
    print("Selected day "+_selectedDay.toString());

    print("focused day para "+focusedDay.toString());
    print("focused day "+_focusedDay.toString());*/

    //if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        isDateSelected=true;
        _rangeStart = null;
        _rangeEnd = null;
      });
    //}

  }

  //Add Appointments
  Future<void> addAppointments() async {
    try{
      await selectTime(context);
      if(selectedEvents[_selectedDay]!=null){
        setState(() {
          selectedEvents[_selectedDay]!.add(Event(
            title: widget.name,
            time: picked,
          )
          );
        });

      }else{
        setState(() {
          selectedEvents[_selectedDay] = [
            Event(
              title: widget.name,
              time: picked,
            )
          ];
        });

      }

      print(selectedEvents);


    }
    catch(e){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("#7 Unable to perform operation. Please check your connection")));
    }




}

  //Appointment Cards
  Widget cards(String s, TimeOfDay t)=> Card(
      child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(s),
                  Text(
                      //(t.hour <= 9? "0"+ t.hour.toString() : t.hour.toString()) + (t.minute <= 9? ":0"+t.minute.toString() : ":"+t.minute.toString())
                    t.format(context).toString()
                  ),
                  //Delete Appointments
                  IconButton(
                    alignment: Alignment.centerRight,
                    onPressed: ()async{
                      try{
                        String deleteDoc="";//for id to doc to be deleted
                        await FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid).collection("Appointments").
                        where('name', isEqualTo:s).where('appoTime',isEqualTo: t.toString().substring(10,12)+":"+t.toString().substring(13,15)).get().then((querySnapshot) => {
                          querySnapshot.docs.forEach((DocumentSnapshot element) {
                            deleteDoc = element.id.toString(); //get the id of the doc by searching by time and name
                            //print(patientId);
                          })
                        });

                        //delete the doc by passing its id
                        await FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid).collection("Appointments").doc(deleteDoc).delete()
                            .then((value) async
                        {
                          await setNextAppoAfterDelete(s);
                        });

                        setState(() {
                          getEventsfromDay(_selectedDay).removeWhere((element) => element.title == s && element.time==t );

                        });

                      }
                      catch(e){
                        print(e);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("#8 Unable to perform operation. Please check your connection")));
                      }


                      },
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
            ],
          )
      ),
  );




  //Table Calendar and events
  @override
  Widget build(BuildContext context) {
    //_onDaySelected(_selectedDay,_focusedDay);

    return FutureBuilder(
      future:  _future,
      builder: (context,snapshot){
    if(snapshot.connectionState== ConnectionState.done){
      return Scaffold(

        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              TableCalendar(
                firstDay:  DateTime.now(),
                lastDay:  DateTime.utc(2100, 12, 31),


                focusedDay: _focusedDay,



                rangeStartDay: _rangeStart,
                rangeEndDay: _rangeEnd,
                calendarFormat: _calendarFormat,
                startingDayOfWeek: StartingDayOfWeek.monday,
                onDaySelected: _onDaySelected,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: getEventsfromDay,
              ),
              ...getEventsfromDay(_selectedDay).map((Event event) => cards(event.title, event.time)),
              //Padding for add appointment buttons
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    Visibility(
                      visible: widget.isFromContactDetails?(isDateSelected?true:false):false,
                      child: FloatingActionButton.extended(

                        onPressed: () async {
                          try{
                            await addAppointments();
                            String uid = _auth.currentUser!.uid;
                            await DatabaseService(uid: uid).createSubcollectionForAppointments(
                                mobile:widget.mobile,
                                pid:widget.patID,
                                name:widget.name,
                                appoDate:_selectedDay.toString(),
                                appoTime:(picked.toString().substring(10,12)+":"+picked.toString().substring(13,15))).then((value) =>
                            {
                              setNextAppo()
                            });

                          }
                          catch(e){
                            print(e);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("#9 Unable to perform operation. Please check your connection")));
                          }


                          },
                        label: Text("Add Appointments"),
                        icon: Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              ),

              Visibility(
                visible: widget.isFromContactDetails?(isDateSelected?false:true):false,
                child: Text(
                    "Tap on a Date to add Appointment",
                    style:GoogleFonts.roboto(fontSize: 20,color: Colors.pink,fontWeight: FontWeight.bold)
                ),
              )
            ],
          ),
        ),
      );
    }
    else{
      return Center(
        child: CircularProgressIndicator(),
      );
    }
      },
    );
  }

  Future setNextAppo() async {

    DateTime minDt = DateTime.parse("2100-01-01 00:00:00Z");
    try{
      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection("Appointments")
          .where('name',isEqualTo: widget.name)/*.orderBy('appoDate')*/
          .get().then((value) => {
        value.docs.forEach((element) async {
          DateTime Dt = DateTime.parse(element.data()['appoDate']);
          if(Dt.isBefore(minDt)){
            minDt = Dt;
          }

        }

        ),
        //print(_nextAppo),
        print("before setting nextAppo")
      }).then((value) async {
        await FirebaseFirestore.instance.collection('users').doc(
            FirebaseAuth.instance.currentUser!.uid).
        collection('PatientList').doc(widget.patID).set(
            {'nextAppo': minDt.toString()},
            SetOptions(merge: true));
      });


    }
    catch(e){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("#10 Unable to perform operation. Please check your connection")));
    }


  }


  Future setNextAppoAfterDelete(String name) async{
    //to set nextAppo in "Patientlist->patient doc" to 'not assigned'
    String patID_ofPat_toBeDeleted = " ";
    String nextAppoStatus = "";
    DateTime minDt = DateTime.parse("2100-01-01 00:00:00Z");

    //get patDoc from Patientlist
    try{
      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection("PatientList").
      where('name', isEqualTo: name).get().then((value) => {
        value.docs.forEach((element) {
          patID_ofPat_toBeDeleted = element.id.toString();
        })
      });
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
        collection('PatientList').doc(patID_ofPat_toBeDeleted).set(
            {'nextAppo': nextAppoStatus},
            SetOptions(merge: true));
      });

    }
    catch(e){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("#11 Unable to perform operation. Please check your connection")));
    }


  }


}