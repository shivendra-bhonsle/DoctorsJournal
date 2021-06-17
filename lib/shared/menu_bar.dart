import 'package:flutter/material.dart';
import 'package:doctors_diary/shared/profile_page.dart';
import 'package:doctors_diary/shared/patient_list_page.dart';
import 'package:doctors_diary/shared/Calender_page.dart';
import 'package:doctors_diary/shared/Settings_page.dart';
import 'package:doctors_diary/shared/Developers_page.dart';

class MenuBar extends StatelessWidget {
  const MenuBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blue,
        child: ListView(
          children: <Widget>[
            SizedBox(height: 12.0,),
            MenuItems(
              text: 'Profile',
              icon: Icons.person,
              onClicked: () => selectedItem(context, 0),
            ),
            SizedBox(height: 12.0,),
            MenuItems(
              text: 'Patient List',
              icon: Icons.people,
              onClicked: () => selectedItem(context, 1),
            ),
            SizedBox(height: 12.0,),
            MenuItems(
              text: 'Calender',
              icon: Icons.calendar_today,
              onClicked: () => selectedItem(context, 2),
            ),
            SizedBox(height: 12.0,),
            MenuItems(
              text: 'Settings',
              icon: Icons.settings,
              onClicked: () => selectedItem(context, 3),
            ),
            SizedBox(height: 12.0,),
            Divider(color: Colors.black,),
            SizedBox(height: 12.0,),
            MenuItems(
              text: 'Developers',
              icon: Icons.people_alt,
              onClicked: () => selectedItem(context, 4),
            ),
            SizedBox(height: 12.0,),
            MenuItems(
              text: 'Quit',
              icon: Icons.power_settings_new,
            ),
          ],
        ),
      ),
    );
  }
  Widget MenuItems({
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    final color = Colors.black;
    return ListTile(
      leading: Icon(icon, color: color,),
      title: Text(text, style: TextStyle(color: color),),
      onTap: onClicked,
    );
  }
  void selectedItem(BuildContext context, int index){
    switch(index){
      case 0:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Profile(),
        ));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PatientList(),
        ));
        break;
      case 2:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Calender(),
        ));
        break;
      case 3:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Settings(),
        ));
        break;
      case 4:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Developers(),
        ));
        break;
    }
  }
}