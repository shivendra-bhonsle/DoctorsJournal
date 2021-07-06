import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:doctors_diary/navigationBar/pages/Calender_page.dart';
import 'package:doctors_diary/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  FirebaseAuth _auth=FirebaseAuth.instance;
  // bool _isEditingAge = false;
  // TextEditingController _editingControllerAge = new TextEditingController();
  // String initialAge = "00";



  @override
  Widget build(BuildContext context) {
    List<String> actions=<String>[
      'Edit',
      'Delete'
    ];

    FirebaseAuth _auth = FirebaseAuth.instance;
    int age = 0;
    String description = 'Sample Text';

    @override
    void initState(){
      super.initState();
      _editingControllerNotes = TextEditingController(text: initialText);
      //_editingControllerAge = TextEditingController(text: initialAge);
    }

    @override
    void dispose(){
      _editingControllerNotes.dispose();
      super.dispose();
    }

    Widget _editTitleTextField() {
      if (_isEditingText) {
        return TextField(
          onSubmitted: (newValue) {
            setState(() {
              if (newValue != '') {
                initialText = newValue;
              }
              else{
                initialText = 'Tap to edit notes...';
              }
              _isEditingText = false;
            });
          },
          autofocus: true,
          controller: _editingControllerNotes,
          style: TextStyle(color: Colors.blue[900], fontSize: 20),
        );
      }
      return InkWell(
          onTap: () {
        setState(() {
          _isEditingText = true;
        });
      },
      child: Text(
      initialText,
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


            SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width-10,
                height: 300.8,
                //color: Colors.teal[50],
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Age: $age', style: TextStyle(fontSize: 22),),
                        SizedBox(width: 10,),
                        //_editTitleTextFieldAge(),
                        SizedBox(width: 40,),
                        IconButton(
                          splashRadius: 20,
                          onPressed: (){

                          },
                          icon: Icon(Icons.edit_outlined),
                          iconSize: 25,

                        )
                      ],
                    ),
                    SizedBox(height: 15,),
                    Text('Next Appointment: ', style: TextStyle(fontSize: 22), textAlign: TextAlign.left, ),
                    SizedBox(height: 25,),
                    Text('Last Appointment: ', style: TextStyle(fontSize: 22),),
                    SizedBox(height: 25,),
                    Text('Notes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    // SizedBox(height: 5,),
                    _editTitleTextField()

                  ],
                ),
              ),
            )
          ],
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
          widget.contact.info!.phones!.elementAt(0).value.toString(), 50, 65, 'DD/MM/YYYY', 'dd/mm/yyyy', _editingControllerNotes.text);
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
}
