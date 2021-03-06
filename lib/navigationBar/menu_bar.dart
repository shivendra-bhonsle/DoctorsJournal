import 'dart:io';
import 'package:doctors_diary/navigationBar/pages/AboutUs.dart';
import 'package:doctors_diary/screens/authenticate/loginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:doctors_diary/navigationBar/pages/profile_page.dart';
import 'package:doctors_diary/navigationBar/pages/Contacts/patient_list_page.dart';
import 'package:doctors_diary/navigationBar/pages/Calendar/Calender_page.dart';
import 'package:doctors_diary/navigationBar/pages/Settings_page.dart';
import 'package:doctors_diary/navigationBar/pages/Developers/Developers_page.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuBar extends StatelessWidget {
  const MenuBar({Key? key}) : super(key: key);
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blue[400],
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
              text: 'Contact List',
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
            MenuItems(
              text: 'Report a Bug',
              icon: Icons.bug_report,
              onClicked: () => _launchURL("https://forms.gle/aYBfukrhuuBTnWks8"),
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
              text: 'About Us',
              icon: Icons.info,
              onClicked: () => selectedItem(context, 5),
            ),
            SizedBox(height: 12.0,),
            MenuItems(
                text: 'Log Out',
                icon: Icons.logout,
                onClicked: () => selectedItem(context, 6),
            ),
            SizedBox(height: 12.0,),
            MenuItems(
              text: 'Quit',
              icon: Icons.power_settings_new,
              onClicked: () => exit(0)
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
  Future<void> selectedItem(BuildContext context, int index) async {
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
          builder: (context) => CalendarPage(),
        ));
        break;
      case 3:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SettingsPage(),
        ));
        break;
      case 4:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => Developers(),
        ));
        break;
      case 5:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AboutUs(),
        ));
        break;
      case 6:
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
        //               Navigator.pushReplacement(context,
        //                 MaterialPageRoute(
        //                     builder: (BuildContext context) => LoginScreen()),);
        break;
    }
  }
}