import 'package:doctors_diary/navigationBar/pages/Developers/developerCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class Developer{
  final String name;
  final String image;
  final Color color;
  final String linkedUrl;
  final String gitHubUrl;
  final String emailUrl;

  Developer({required this.linkedUrl,
    required this.gitHubUrl,
    required this.emailUrl,
    required this.name,
    required this.image,
    required this.color,});


}
class Developers extends StatefulWidget {
  //const Developers({Key? key}) : super(key: key);


  @override
  _DevelopersState createState() => _DevelopersState();
}

class _DevelopersState extends State<Developers> {
  final developerList = [
    Developer(
        name: 'Shivendra Bhonsle',
        image: 'assets/images/shivendra.jpg',
        gitHubUrl: "https://github.com/shivendra-bhonsle",
        linkedUrl: "https://www.linkedin.com/in/shivendra-bhonsle-b6243a1b2/",
        emailUrl: "shivendrabhonsle28@gmail.com",
        color: Colors.blue.shade300),
    Developer(
        name: 'Rajas Chitale',
        image: 'assets/images/rajas.jpg',
        gitHubUrl: "https://github.com/rajas1310",
        linkedUrl: "https://www.linkedin.com/in/rajas-chitale-46512b193/",
        emailUrl: "rajaschitale@gmail.com",
        color: Colors.blue.shade300),
    Developer(
        name: 'Varad Patwardhan',
        image: 'assets/images/varad.jpeg',
        gitHubUrl: "https://github.com/Varad0210",
        linkedUrl: "https://www.linkedin.com/in/varad-patwardhan-96431a197",
        emailUrl: "varadp2000@gmail.com",
        color: Colors.blue.shade300),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Text('Developers',
            style: TextStyle(fontFamily: 'Raleway', fontSize: 30.0,),),

          centerTitle: true,
          backgroundColor: Colors.blue[900],

        ),
        body: Column(

          children: [
            DeveloperCard(dev: developerList[0],),
            DeveloperCard(dev: developerList[1],),
            DeveloperCard(dev: developerList[2],),

          ],
        )

    );
  }
}