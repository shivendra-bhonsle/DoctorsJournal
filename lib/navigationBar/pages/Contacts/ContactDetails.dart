import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:doctors_diary/navigationBar/pages/Calendar/Calender_page.dart';
import 'package:doctors_diary/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'AppContact.dart';

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
  TextEditingController ageController = new TextEditingController();
  String initialText = "Tap to edit notes...";
  String patDocId = "";
  String description = "Loading data... Please wait";
  String age = "...";
  String nextAppo = "Not assigned";
  String lastAppo = "Not assigned";
  FirebaseAuth _auth = FirebaseAuth.instance;


  @override
  void initState() {
    super.initState();
    _editingControllerNotes = TextEditingController(text: initialText);
    fetchPatientData();
  }

  @override
  void dispose() {
    _editingControllerNotes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> actions = <String>[
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
              else if(initialText == ""){
                initialText = "Tap to edit notes...";
              }
              else {
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
              if(str == "Tap to edit notes..."){
                _editingControllerNotes.text = "";
              }else{
                _editingControllerNotes.text = str;
              }

              //_editingControllerNotes.text == "Tap to edit notes..."?  "" : str;
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


    showDeleteConfirmation() {
      Widget cancelButton = TextButton(onPressed: () {
        Navigator.of(context)
            .pop(); //here context is of builder implemented below
      }, child: Text('Cancel'));

      Widget deleteButton = TextButton(
          style: TextButton.styleFrom(primary: Colors.red),
          onPressed: () async {
            await ContactsService.deleteContact(widget.contact
                .info!); //passing the contact to main contact app for deleting it
            widget.onContactDelete(widget.contact);
            Navigator.of(context).pop();
          },
          child: Text('Delete')
      );
      AlertDialog alert = AlertDialog(
        title: Text('Delete Contact'),
        content: Text('Are you sure you want to delete this contact?'),
        actions: [cancelButton, deleteButton],
      );

      showDialog(
          context: context,
          builder: (
              BuildContext context) { //we implementing builder here so we can show dialog if we press cancel
            return alert;
          }
      );
    }

    onAction(String action) async {
      //perform action based on what is passed
      switch (action) {
        case 'Edit':
          try {
            Contact updatedContact = await ContactsService.openExistingContact(
                widget.contact.info!);
            setState(() {
              widget.contact.info = updatedContact;
            });
            widget.onContactUpdate(widget.contact);
          } on FormOperationException catch (e) {
            // TODO
            switch (e.errorCode) {
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
                              (child: Text(widget.contact.info!.initials(),
                              textScaleFactor: 2.0,),
                              maxRadius: 50.0,

                            )),
                        SizedBox(height: 10.0,),
                        Text(
                          widget.contact.info!.displayName.toString(),
                          style: TextStyle(fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto-Bold'),
                        ),
                        SizedBox(height: 10.0,),
                        Text(
                          widget.contact.info!.phones!.elementAt(0).value
                              .toString(),
                          style: TextStyle(fontSize: 20.0,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Roboto-Light'),
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
                          itemBuilder: (BuildContext context) {
                            return actions.map((String action) {
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
                width: MediaQuery
                    .of(context)
                    .size
                    .width - 10,
                height: 500,
                //300.8,
                color: Colors.transparent,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: FutureBuilder(
                  future: FirebaseFirestore.instance.collection('users').doc(
                      _auth.currentUser!.uid)
                      .collection('PatientList').doc(
                      DatabaseService(uid: _auth.currentUser!.uid)
                          .getDocIdOfPatient(
                          widget.contact.info!.displayName.toString(),
                          widget.contact.info!.phones!.elementAt(0).value
                              .toString()
                      )
                          .toString()
                  )
                      .get().then((doc) =>
                  {
                    print(doc.id),
                    //print(doc.data()),

                    age = doc.data()!['age'].toString(),
                    description = doc.data()!['description'].toString(),
                    nextAppo = doc.data()!['nextAppo'].toString(),
                    lastAppo = doc.data()!['lastAppo'].toString(),


                    print(age)
                  }),
                  builder: (context, snapshot) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        //SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('Age: ', style: TextStyle(fontSize: 22),),
                            SizedBox(width: 10,),
                            Text("$age years", style: GoogleFonts.roboto(
                                fontSize: 22, fontWeight: FontWeight.bold)),

                            SizedBox(width: 40,),
                            IconButton(
                              splashRadius: 20,
                              onPressed: () {
                                createAlertDialogForAge(context).then((
                                    value) async {
                                  if (value!.isNotEmpty) {
                                    //age = value.toString();
                                    await editAge();
                                  }
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                          super.widget));
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
                            Text('Next Appointment: ',
                              style: TextStyle(fontSize: 22),
                              textAlign: TextAlign.left,),
                            Text(
                              nextAppo,
                              style: TextStyle(color: Colors.green,fontSize: 20,fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),

                          ],
                        ),
                        SizedBox(height: 20,),
                        Row(
                          children: [
                            Text('Last Appointment: ',
                              style: TextStyle(fontSize: 22),),
                            Text(
                              lastAppo,
                              style: TextStyle(color: Colors.red,fontSize: 20,fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),

                          ],
                        ),
                        SizedBox(height: 20,),
                        Text('Notes (tap to edit)', style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),),
                        Container(padding: EdgeInsets.all(12), width: double.infinity, color: Colors.teal[50], child: _editTitleTextField(description))



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
        height: 60/* MediaQuery.of(context).size.height - 780*/,
        margin: EdgeInsets.only(bottom: 10),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        CalendarPage(
                          name: widget.contact.info!.displayName.toString(),
                          mobile: widget.contact.info!.phones!.elementAt(0)
                              .value.toString(),
                          isFromContactDetails: true,
                          patID: patDocId,)));
              },
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
  Future editNotes() async {
    //passing age variable from ContactDetailsState class because this function is outside that class so "age" can't be accessed directly
    String patID = "";

      //if patient is already present
    try{
      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .getDocIdOfPatient( //find the id of that patient
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
    catch(e){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("#2 Unable to perform operation. Please check your connection")));
          }

    //}
  }



  Future<void> fetchPatientData() async {
    try{
      String patID = "";
      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .getDocIdOfPatient(
          widget.contact.info!.displayName.toString(),
          widget.contact.info!.phones!.elementAt(0).value.toString()).then((
          value) =>
      {
        setState(() {
          patID = value.toString();
          patDocId = patID; //variable used to pass patientID to the calendar
        })
      });
      print("PatId For Age: $patID");

      //getting age
      await DatabaseService(uid: _auth.currentUser!.uid)
          .getPatientAge(patID)
          .then((value) =>
      {
        setState(() {
          age = value.toString();
        })
      });
      print(age);

      //getting description
      DatabaseService(uid: _auth.currentUser!.uid).getPatientDesc(patID).then((
          value) =>
      {
        setState(() {
          description = value.toString();
        })
      });
      print(description);

      //getting nextAppo
      DatabaseService(uid: _auth.currentUser!.uid)
          .getPatientNextAppo(patID)
          .then((value) =>
      {
        setState(() {
          nextAppo=value.toString()=="Not assigned"?"Not assigned": DateFormat("dd-MM-yy").format(DateTime.parse(value.toString()));
          //= value.toString();
        })
      });
      print(nextAppo);

      //getting lastAppo
      DatabaseService(uid: _auth.currentUser!.uid)
          .getPatientLastAppo(patID)
          .then((value) =>
      {
        setState(() {
          lastAppo = value.toString()=="Not assigned"?"Not assigned": DateFormat("dd-MM-yy").format(DateTime.parse(value.toString()));
        })
      });
      print(lastAppo);

    }
    catch(e){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("#3 Unable to perform operation. Please check your connection")));
    }

  }


  Future<String?> createAlertDialogForAge(BuildContext context) {
    //TextEditingController ageController = TextEditingController();
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("Enter patient's age"),
        content: TextField(
          controller: ageController,
          keyboardType: TextInputType.number,
        ),
        actions: [
          MaterialButton(
              elevation: 5.0,

              child: Text('Update', style: TextStyle(color: Colors.blue),),
              onPressed: () {
                if (ageController.text
                    .toString()
                    .isNotEmpty) {
                  // setState(() {
                  //   age = ageController.text.toString();
                  // });

                  Navigator.of(context).pop(ageController.text.toString());
                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Please enter age"),
                  ));
                }
              }),
        ],
      );
    });
  }

  Future editAge(/*String newAge*/) async {
    String patID = "";
    try{
      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .getDocIdOfPatient( //find the id of that patient
          widget.contact.info!.displayName.toString(),
          widget.contact.info!.phones!.elementAt(0).value
              .toString())
          .then((value) {
        setState(() {
          patID = value.toString();
          print(patID);
        });
      });

      await FirebaseFirestore.instance.collection('users').doc(
          FirebaseAuth.instance.currentUser!.uid).
      collection('PatientList').doc(patID).set(
          {'age': ageController.text},
          SetOptions(merge: true));

    }
    catch(e){
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("#4 Unable to perform operation. Please check your connection")));
    }
      //if patient is already present

    //}
  }
}