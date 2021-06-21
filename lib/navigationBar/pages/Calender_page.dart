import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calender extends StatelessWidget {
  const Calender({Key? key}) : super(key: key);

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
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          selectedDayPredicate: (day)
          {
            if (_selectedDay == day) {
              return true;
            }
            else {
              return false;
            }
          },
          onDaySelected: (selectedDay, focusedDay) {
            if (_selectedDay != selectedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            }
          },
          onPageChanged: (focusedDay)
          {
            _focusedDay = focusedDay;
          },
        ),
    );
  }
}
