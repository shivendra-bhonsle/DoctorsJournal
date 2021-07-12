import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:doctors_diary/models/patient.dart';
import 'package:doctors_diary/navigationBar/pages/Calender_page.dart';
import 'package:doctors_diary/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'AppContact.dart';
import 'package:doctors_diary/services/database.dart';
//CONTACT DETAILS PAGE

class ContactDetails extends StatefulWidget {
  final AppContact contact;
  final Function(AppContact) onContactUpdate;
  final Function(AppContact) onContactDelete;


  const ContactDetails(this.contact, {required this.onContactUpdate, required this.onContactDelete});

  @override
  _ContactDetailsState createState() => _ContactDetailsState();
}

class _ContactDetailsState extends State<ContactDetails> {
  //setting up editable text widget for Notes
  bool _isEditingText = false;
  TextEditingController _editingControllerNotes = new TextEditingController();
  String initialText = "Tap to edit notes...";
  String description = "Loading data... Please wait";
  String age = "...";
  String nextAppo = "...";
  String lastAppo = "...";
  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  FirebaseAuth _auth=FirebaseAuth.instance;

  // bool _isEditingAge = false;
  // TextEditingController _editingControllerAge = new TextEditingController();
  // String initialAge = "00";


  @override
  void initState(){
    super.initState();
    _editingControllerNotes = TextEditingController(text: initialText);
    //getPatientData();
    //_editingControllerAge = TextEditingController(text: initialAge);
    //fetchDescription();
    //fetchAge();
    fetchPatientData();
  }

  @override
  void dispose(){
    _editingControllerNotes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> actions=<String>[
      'Edit',
      'Delete'
    ];

    FirebaseAuth _auth = FirebaseAuth.instance;



    Widget _editTitleTextField(String str) {
      if (_isEditingText) {
            return TextField(
              onSubmitted: (newValue) {
                setState(() {
                  if (newValue != "") {
                    initialText = newValue;
                  }
                  else{
                    // initialText = snapshot.hasData? (snapshot.data() as dynamic)['description'] : 'Tap to edit...';
                       initialText = str;
                    //   initialText = snapshot.data()['description'];

                  }
                  _isEditingText = false;
                });
              },
              autofocus: true,
              controller: _editingControllerNotes,
              style: TextStyle(color: Colors.blue[900], fontSize: 20),
              maxLines: 6,
              //expands: true,
            );
      }
      return InkWell(
          onTap: () {
            setState(() {
              _editingControllerNotes.text = str;
              _isEditingText = true;
            });
          },
          child: Text(
            str,
            style: TextStyle(
              color: Colors.blue[900],
              fontSize: 20.0,
            ),
            //textAlign: TextAlign.start,
          )
      );
    }



    showDeleteConfirmation(){
      Widget cancelButton=TextButton(onPressed: (){
        Navigator.of(context).pop();//here context is of builder implemented below
      }, child: Text('Cancel'));

      Widget deleteButton=TextButton(
          style: TextButton.styleFrom(primary: Colors.red),
          onPressed: () async{
            await ContactsService.deleteContact(widget.contact.info!);//passing the contact to main contact app for deleting it
            widget.onContactDelete(widget.contact);
            Navigator.of(context).pop();

          },
          child: Text('Delete')
      );
      AlertDialog alert=AlertDialog(
        title: Text('Delete Contact'),
        content: Text('Are you sure you want to delete this contact?'),
        actions: [cancelButton,deleteButton],
      );

      showDialog(
          context: context,
          builder: (BuildContext context){//we implementing builder here so we can show dialog if we press cancel
            return alert;
          }
      );
    }

    onAction(String action) async{//perform action based on what is passed
      switch(action){
        case 'Edit':
          try {
            Contact updatedContact=await ContactsService.openExistingContact(widget.contact.info!);
            setState(() {
              widget.contact.info=updatedContact;
            });
            widget.onContactUpdate(widget.contact);
          } on FormOperationException catch (e) {
            // TODO
            switch(e.errorCode){
              case FormOperationErrorCode.FORM_OPERATION_CANCELED:
              case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
              case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
                print(e.toString());
            }
          }
          break;
        case 'Delete':
          showDeleteConfirmation();
          break;

      }
    }
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
                children: [
                  Container(
                    height: 180,
                    decoration: BoxDecoration(color: Colors.grey[300]),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        Column(
                          children: [
                            Center(

                                child: CircleAvatar
                                  (child:Text(widget.contact.info!.initials() ,textScaleFactor: 2.0,),
                                  maxRadius: 50.0,

                                )),
                            SizedBox(height: 10.0,),
                            Text(
                              widget.contact.info!.displayName.toString(),
                              style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold,fontFamily: 'Roboto-Bold'),
                            ),
                            SizedBox(height: 10.0,),
                            Text(
                              widget.contact.info!.phones!.elementAt(0).value.toString(),
                              style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.normal,fontFamily: 'Roboto-Light'),
                            )

                          ],
                        ),
                        Align(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          alignment: Alignment.topLeft,
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: PopupMenuButton(
                              onSelected: onAction,
                              itemBuilder: (BuildContext context){
                                return actions.map((String action){
                                  return PopupMenuItem(
                                    value: action,
                                    child: Text(action),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        )

                      ],
                    ),
                  ),



                  Container(
                    width: MediaQuery.of(context).size.width-10,
                    height: 500,//300.8,
                    color: Colors.transparent,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: FutureBuilder(
                      future: FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid)
                            .collection('PatientList') .doc(
                          DatabaseService(uid: _auth.currentUser!.uid).getDocIdOfPatient(
                              widget.contact.info!.displayName.toString(),
                              widget.contact.info!.phones!.elementAt(0).value.toString()
                          ).toString()
                        )
                            .get().then((doc) => {
                          print(doc.id),
                          //print(doc.data()),

                            age = doc.data()!['age'].toString(),
                            description = doc.data()!['description'].toString(),
                            nextAppo = doc.data()!['nextAppo'].toString(),
                            lastAppo = doc.data()!['lastAppo'].toString(),


                          print(age)

                        }),
                      builder: (context, snapshot){
                        //if(snapshot.connectionState != ConnectionState.done){
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              //SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('Age: ', style: TextStyle(fontSize: 22),),
                                  SizedBox(width: 10,),
                                  Text("$age years", style: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.bold)),
                                  // FutureBuilder(
                                  //     future:  FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid)
                                  //         .collection('PatientList') .doc(
                                  //       DatabaseService(uid: _auth.currentUser!.uid).getDocIdOfPatient(
                                  //           widget.contact.info!.displayName.toString(),
                                  //           widget.contact.info!.phones!.elementAt(0).value.toString()
                                  //       ).toString()
                                  //     )
                                  //         .get().then((doc) => {
                                  //       print(doc.id),
                                  //       //print(doc.data()),
                                  //       age = doc.data()!['age'].toString(),
                                  //       print(age)
                                  //
                                  //     }),
                                  //     builder: (context, snapshot){
                                  //       if(snapshot.connectionState != ConnectionState.done)
                                  //         return Text("Loading...");
                                  //       return Text(age);
                                  //     }),
                                  // FutureBuilder(
                                  //     future: DatabaseService(uid: _auth.currentUser!.uid).getPatientAge(DatabaseService(uid: _auth.currentUser!.uid)
                                  //         .getDocIdOfPatient(widget.contact.info!.displayName.toString(),
                                  //         widget.contact.info!.phones!.elementAt(0).value
                                  //             .toString()).toString()),
                                  //     builder: (context, snapshot){
                                  //       if(snapshot.connectionState != ConnectionState.done)
                                  //         return Text("Loading...");
                                  //       return Text(age);
                                  // }),
                                  //_editTitleTextFieldAge(),
                                  SizedBox(width: 40,),
                                  IconButton(
                                    splashRadius: 20,
                                    onPressed: (){
                                      createAlertDialogForAge(context).then((value) {
                                        if(value!.isNotEmpty){
                                          editAge(value.toString());

                                        }
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (BuildContext context) => super.widget));
                                      });
                                    },
                                    icon: Icon(Icons.edit_outlined),
                                    iconSize: 25,

                                  )
                                ],
                              ),
                              SizedBox(height: 10,),
                              Row(
                                children: [
                                  Text('Next Appointment:', style: TextStyle(fontSize: 22), textAlign: TextAlign.left, ),
                                  Card(color: Colors.white,
                                      elevation:1 ,
                                      child: Text(" $nextAppo", style: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[700]),),
                                  )
                                ],
                              ),
                              SizedBox(height: 20,),
                              Row(
                                children: [
                                  Text('Last Appointment: ', style: TextStyle(fontSize: 22),),
                                  Card(color: Colors.white,
                                    elevation: 1,
                                    child: Text(" $lastAppo", style: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown[900]),),
                                  )
                                ],
                              ),
                              SizedBox(height: 20,),
                              Text('Notes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                              _editTitleTextField(description)

                              // FutureBuilder(
                              //     future: DatabaseService(uid: _auth.currentUser!.uid).getPatientDesc(DatabaseService(uid: _auth.currentUser!.uid)
                              //         .getDocIdOfPatient(widget.contact.info!.displayName.toString(),
                              //         widget.contact.info!.phones!.elementAt(0).value
                              //             .toString()).toString()),
                              //     builder: (context, snapshot){
                              //       if(snapshot.connectionState != ConnectionState.done)
                              //         return _editTitleTextField("Loading data... Please wait");
                              //       return _editTitleTextField(description);
                              //     }
                              // ),

                            ],
                          );
                        // }
                        // else{
                        //   return Center(child: CircularProgressIndicator());
                        // }
                      },

                    ),
                  ),

                ],

              ),

        ),
      ),
        bottomSheet: Container(
          height: MediaQuery.of(context).size.height-780,
          margin: EdgeInsets.only(bottom: 10),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed:(){
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context)=>CalendarPage()));                },
                child: Text('Add Appointment',
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Roboto-bold',
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(primary: Colors.green[700]),
              ),

              ElevatedButton(
                onPressed: () async {
                  await editNotes(); //calling function to edit description
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => super.widget));

                },
                child: Text('Save',
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Roboto-bold',
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(primary: Colors.blue[700]),

              ),
            ],
          ),
        ),

    );
  }

  //function to edit description
  Future editNotes() async{
    String patID="";
    var isPatientPresent=false;

    await _firestore
        .collection('users').doc(_auth.currentUser!.uid).collection('PatientList')
        .where('name', isEqualTo: widget.contact.info!.displayName.toString())
        .where('phoneno', isEqualTo: widget.contact.info!.phones!.elementAt(0).value.toString())//check if a doc of patient with same mobile number is already present
        .get()
        .then((result) {

      if(result.docs.length>0){
        setState((){
          isPatientPresent = true;//if yes then set patient present to true
        });
      }

    });
    if(isPatientPresent==false){//if patient is not present create new doc and set the desc as given
      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .createSubcollectionForPatientList(widget.contact.info!.displayName.toString(),
          widget.contact.info!.phones!.elementAt(0).value.toString(), 50, 'DD/MM/YYYY', 'dd/mm/yyyy', _editingControllerNotes.text);
    }
    else {
      //if patient is already present
      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .getDocIdOfPatient(//find the id of that patient
          widget.contact.info!.displayName.toString(),
          widget.contact.info!.phones!.elementAt(0).value
              .toString())
          .then((value) {
        setState(() {
          patID = value.toString();
          print(patID);
        });
      });

      //update the desc
      FirebaseFirestore.instance.collection('users').doc(
          FirebaseAuth.instance.currentUser!.uid).collection('PatientList').doc(
          patID).set(
          {'description': _editingControllerNotes.text},
          SetOptions(merge: true));
    }
  }

  // Future<void> fetchDescription() async {
  //   String patID = "";
  //   await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
  //       .getDocIdOfPatient(
  //       widget.contact.info!.displayName.toString(),
  //       widget.contact.info!.phones!.elementAt(0).value.toString()).then((value) =>
  //   {
  //     setState((){
  //       patID = value.toString();
  //     })
  //   });
  //   print(patID);
  //   await DatabaseService(uid: _auth.currentUser!.uid).getPatientDesc(patID).then((value) =>
  //   {
  //     setState((){
  //       description = value.toString();
  //     })
  //   });
  //   print(description);
  // }
  //
  // //Fetching age
  // Future<void> fetchAge() async {
  //   String patID = "";
  //   await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
  //       .getDocIdOfPatient(
  //       widget.contact.info!.displayName.toString(),
  //       widget.contact.info!.phones!.elementAt(0).value.toString()).then((value) =>
  //   {
  //     setState((){
  //       patID = value.toString();
  //     })
  //   });
  //   print("PatId For Age: $patID");
  //   await DatabaseService(uid: _auth.currentUser!.uid).getPatientAge(patID).then((value) =>
  //   {
  //     setState((){
  //       age = value.toString();
  //     })
  //   });
  //   print(age);
  // }

  Future<void> fetchPatientData() async {
    String patID = "";
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getDocIdOfPatient(
        widget.contact.info!.displayName.toString(),
        widget.contact.info!.phones!.elementAt(0).value.toString()).then((value) =>
    {
      setState((){
        patID = value.toString();
      })
    });
    print("PatId For Age: $patID");

    //getting age
    await DatabaseService(uid: _auth.currentUser!.uid).getPatientAge(patID).then((value) =>
    {
      setState((){
        age = value.toString();
      })
    });
    print(age);

    //getting description
    DatabaseService(uid: _auth.currentUser!.uid).getPatientDesc(patID).then((value) =>
    {
      setState((){
        description = value.toString();
      })
    });
    print(description);

    //getting nextAppo
    DatabaseService(uid: _auth.currentUser!.uid).getPatientNextAppo(patID).then((value) =>
    {
      setState((){
        nextAppo = value.toString();
      })
    });
    print(nextAppo);

    //getting lastAppo
    DatabaseService(uid: _auth.currentUser!.uid).getPatientLastAppo(patID).then((value) =>
    {
      setState((){
        lastAppo = value.toString();
      })
    });
    print(lastAppo);
  }


  Future<String?> createAlertDialogForAge(BuildContext context){

    TextEditingController ageController=TextEditingController();
    return showDialog(context: context,builder: (context){
      return AlertDialog(
        title: Text("Enter patient's age"),
        content: TextField(
          controller: ageController,
          keyboardType: TextInputType.number,
        ),
        actions: [
          MaterialButton(
              elevation: 5.0,

              child: Text('Update',style:TextStyle(color: Colors.blue),),
              onPressed: (){
                if(ageController.text.toString().isNotEmpty){
                  age = ageController.text.toString();
                  Navigator.of(context).pop(ageController.text.toString());
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Please enter age"),
                  ));
                }
              }),
        ],
      );
    });
  }

  Future editAge(String newAge) async{
    String patID = "";
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getDocIdOfPatient(
        widget.contact.info!.displayName.toString(),
        widget.contact.info!.phones!.elementAt(0).value.toString()).then((value) =>
    {
      setState((){
        patID = value.toString();
      })
    });

    await FirebaseFirestore.instance.collection('users').doc(
        FirebaseAuth.instance.currentUser!.uid).
        collection('PatientList').doc(patID).set(
        {'age': newAge},
        SetOptions(merge: true));

  }

}