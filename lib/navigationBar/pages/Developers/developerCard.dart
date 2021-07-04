import 'package:doctors_diary/navigationBar/pages/Developers/Developers_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperCard extends StatelessWidget {
  final Developer dev;
  const DeveloperCard({Key? key,required this.dev}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,

      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15.0,horizontal: 13.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(dev.image),
              radius: 50.0,
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Column(
                  children: [
                    Text(dev.name,textScaleFactor: 1.6,textAlign: TextAlign.center,style:GoogleFonts.roboto(fontWeight: FontWeight.bold ) ,),
                    SizedBox(height: 20.0,),
                    Container(

                      child: Row(
                        //mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: (){
                              _launchURL(dev.gitHubUrl);
                            },
                            icon: SvgPicture.asset("assets/images/github.svg",
                              color: Colors.black,
                              height: 50.0,
                            ),

                          ),
                          SizedBox(width: 15.0,),
                          IconButton(
                            onPressed: (){
                              launchMailto(dev.emailUrl);
                            },
                            icon: Image.asset(
                              "assets/images/gmail.png",
                              // color: Colors.white,
                              height: 50,

                            ),
                            iconSize: 40,),
                          SizedBox(width: 15.0,),
                          IconButton(
                            onPressed: (){
                              _launchURL(dev.linkedUrl);
                            },
                            icon: SvgPicture.asset(
                                "assets/images/linkedin.svg"
                            ),),

                        ],
                      ),
                    ),



                  ],
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }
  _launchURL(String url) async {
    // const url = 'https://www.freeprivacypolicy.com/live/5f912cf6-262a-4f14-8f42-8fdbfd17c050';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  launchMailto( String email) async {
    final mailtoLink = Mailto(
      to: [email],

    );
    // Convert the Mailto instance into a string.
    // Use either Dart's string interpolation
    // or the toString() method.
    await launch('$mailtoLink');
  }
}
