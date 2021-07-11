import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctors_diary/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doctors_diary/services/database.dart';
import 'package:google_fonts/google_fonts.dart';
class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  FirebaseAuth auth=FirebaseAuth.instance;
  String mobile="no val";
  String name="no val";
  @override
  initState() {
    super.initState();
    //setText();


  }
  /*Future<void> setText() async{

    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).fetchName().then((value) => {
      setState((){
        name=value.toString();
      })
    });
    print(name);



  }*/
  //DatabaseService databaseService=DatabaseService(uid: auth.currentUser!.uid);
  Future<String?> createAlertDialog(BuildContext context){
    TextEditingController customController=TextEditingController();
    return showDialog(context: context,builder: (context){
      return AlertDialog(
        title: Text("Enter your Name"),
        content: TextField(
          controller: customController,


        ),

        actions: [
          MaterialButton(
            elevation: 5.0,

              child: Text('Update',style:TextStyle(color: Colors.blue),),
              onPressed: (){
              if(customController.text.toString().isNotEmpty){
                Navigator.of(context).pop(customController.text.toString());

              }
              else{
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Please enter a name"),
                ));
              }
              }),
        ],
      );
    });
  }
  
  
  
  @override
  Widget build(BuildContext context) {
    //setText();
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.indigo[900],

      ),
      body: SafeArea(

        child:FutureBuilder(
          future:  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) {


            name=value.data()!['name'].toString();
            mobile=value.data()!['mobile'].toString();
            print(name);
            print(mobile);


          }),
          builder: (context,snapshot){
            if(snapshot.connectionState== ConnectionState.done){
              return Column(
                children: [
                  Container(

                    width: double.infinity,
                    child:
                    Column(
                      children: [
                        SizedBox(height: 20,),
                        Center(
                          child: CircleAvatar(
                            child: Text(
                              getInitials(name),

                              textScaleFactor: 3.0,
                            ),
                            maxRadius: 50.0,
                          ),
                        ),
                        SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Text(name,

                              style:

                              GoogleFonts.roboto(fontWeight: FontWeight.normal,fontSize: 30, fontStyle: FontStyle.italic),

                            ),
                            IconButton(
                                onPressed: (){
                                  createAlertDialog(context).then((value) {
                                    if(value!.isNotEmpty){
                                      editName(value.toString());

                                    }
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) => super.widget));


                                  });



                                },
                                icon: Icon(Icons.edit),
                              color: Colors.grey,
                            )
                          ],
                        ),


                        SizedBox(height: 20.0,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(mobile,
                            style: GoogleFonts.roboto(fontWeight: FontWeight.bold,fontSize: 20, fontStyle: FontStyle.italic),),

                          ],
                        )

                      ],
                    ),
                  )
                ],
              );
            }
            else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

          },
        )

      ),
    );
  }

  String getInitials(String name) => name.isNotEmpty
      ? name.trim().split(' ').map((l) => l[0]).take(2).join()
      : '';

   Future editName(String newName) async{

     FirebaseFirestore.instance.collection('users').doc(
         FirebaseAuth.instance.currentUser!.uid)..set(
         {'name': newName},
         SetOptions(merge: true));

   }


}
