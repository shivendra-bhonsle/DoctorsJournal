import 'package:flutter/material.dart';

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
            ),
            SizedBox(height: 12.0,),
            MenuItems(
              text: 'Patient List',
              icon: Icons.people,
            ),
            SizedBox(height: 12.0,),
            MenuItems(
              text: 'Calender',
              icon: Icons.calendar_today,
            ),
            SizedBox(height: 12.0,),
            MenuItems(
              text: 'Settings',
              icon: Icons.settings,
            ),
            SizedBox(height: 12.0,),
            Divider(color: Colors.black,),
            SizedBox(height: 12.0,),
            MenuItems(
              text: 'Developers',
              icon: Icons.people_alt,
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
  }) {
    final color = Colors.black;
    return ListTile(
      leading: Icon(icon, color: color,),
      title: Text(text, style: TextStyle(color: color),),
      onTap: () {},
    );
  }
}