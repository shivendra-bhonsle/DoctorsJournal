import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:doctors_diary/shared/appointment_cards.dart';

Widget appointments(){
  return Appointment();
}

class HomeTemp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {},
            icon: Icon(Icons.menu)
        ),
        title: Text("Doctor's Diary"),
        centerTitle: true,
        backgroundColor: Colors.indigo[900],
        actions: <Widget>[
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.person_add),
          ),
        ],
      ),
      body: Column(
        children: [
          appointments()
        ],
      ),
    );
  }
}
