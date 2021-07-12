import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';


//Event Class
class Event {
  final String title;
  final TimeOfDay time;
  Event({required this.title, required this.time});
  String toString() => this.title;
}

class CalendarPage extends StatelessWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calender'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Calendar(),
    );
  }
}

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

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
  final currentDay = DateTime.now();
  TextEditingController _eventController = TextEditingController();

  //To select the time of appointment
  Future<Null> selectTime(BuildContext context) async {
    await showTimePicker(
        context: context,
        initialTime: _time,
    ).then((value) => {
       setState((){
         picked = value!;
       })
    });
  }

  @override
  void initState(){
    selectedEvents = {};
    super.initState();
  }

  //Get events
  List<Event> _getEventsfromDay(DateTime date){
    return selectedEvents[date] ?? [];
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  //Select day
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null;
        _rangeEnd = null;
      });
    }
  }

  //Add Appointments
  void addAppointments(){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Add Appointments"),
          content: TextFormField(controller: _eventController,),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel")
            ),
            TextButton(
                onPressed: () async {
                  if(_eventController.text.isEmpty){
                  }else{
                    await selectTime(context);
                    if(selectedEvents[_selectedDay]!=null){
                      selectedEvents[_selectedDay]!.add((Event(
                        title: _eventController.text,
                        time: picked,
                      )
                      ));
                    }else{
                      selectedEvents[_selectedDay] = [
                        Event(
                          title: _eventController.text,
                          time: picked,
                        )
                      ];
                    }
                  }
                  print(picked);
                  Navigator.pop(context);
                  _eventController.clear();
                  setState(() {});
                  return;
                },
                child: Text("Ok")
            ),
          ],
        )
    );
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
                      (t.hour <= 9? "0"+ t.hour.toString() : t.hour.toString()) + (t.minute <= 9? ":0"+t.minute.toString() : ":"+t.minute.toString())
                  ),
                  //Delete Appointments
                  IconButton(
                    alignment: Alignment.centerRight,
                    onPressed: (){
                      setState(() {
                        _getEventsfromDay(_selectedDay).removeWhere((element) => element.title == s );
                      });
                      },
                    icon: Icon(Icons.delete),
                  )
                ],
              ),
            ],
          )
      ),
  );


  //Table Calendar and events
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              TableCalendar(
                firstDay:  DateTime.utc(2000, 1, 1),
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
                eventLoader: _getEventsfromDay,
              ),
              ..._getEventsfromDay(_selectedDay).map((Event event) => cards(event.title, event.time)),
              //Padding for add appointment buttons
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FloatingActionButton.extended(
                      onPressed: (){
                        addAppointments();
                        },
                      label: Text("Add Appointments"),
                      icon: Icon(Icons.add),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
    );
  }
}