import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:doctors_diary/shared/appointment_cards.dart';
import 'package:doctors_diary/shared/menu_bar.dart';

Widget appointments(){
  return Appointment();
}

class HomeTemp extends StatelessWidget {
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
