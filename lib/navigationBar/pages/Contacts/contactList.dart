import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctors_diary/navigationBar/pages/Contacts/ContactDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doctors_diary/services/database.dart';
import 'AppContact.dart';
import 'package:flutter/material.dart';

//FOR LIST TILE OF EACH CONTACT

class ContactsList extends StatefulWidget {
  final List<AppContact?> contacts;
  Function() reloadContacts;
  ContactsList({Key? key, required this.contacts,required this.reloadContacts}) : super(key: key);

  @override
  _ContactsListState createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isPATPresent = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        //we use this as we are using a List inside column and both are scrollable
        itemCount: widget.contacts.length,
        //condition for which to show
        itemBuilder: (context, index) {
          AppContact? contact = widget.contacts[index];
          String number = "";
          contact!.info!.phones!.forEach((f) {
            number = f.value!;
          });
          return ListTile(
            onTap: () async {
              if (contact.info!.phones!.isNotEmpty) {
                //bool isPatPresent=false;
                await DatabaseService(uid: _auth.currentUser!.uid)
                    .getDocIdOfPatient(contact.info!.displayName.toString(),
                    contact.info!.phones!.elementAt(0).value.toString())
                    .then((value) async =>
                {
                  if(value.toString() == "Not fetched"){
                    await DatabaseService(uid: _auth.currentUser!.uid)
                        .createSubcollectionForPatientList(
                        contact.info!.displayName.toString(),
                        contact.info!.phones!.elementAt(0).value.toString(), "",
                        'DD/MM/YYYY', 'dd/mm/yyyy', "")
                  }
                }
                );


                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        ContactDetails(
                          contact,
                          onContactUpdate: (AppContact _contact) {
                            widget.reloadContacts();
                          },
                          onContactDelete: (AppContact _contact) {
                            widget.reloadContacts();
                            Navigator.of(context)
                                .pop(); //this will take it to contact list page again after contact is deleted
                          },
                        )));
              }
              else { //if a contact does not have a number

                final snackBar = SnackBar(
                    content: Text('Select a contact with a number'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }


              //await DatabaseService(uid: _auth.rrecuntUser!.uid).getPatientByNameAndNumber(contact.info!.displayName.toString(), contact.info!.phones!.elementAt(0).value.toString());

            },
            title: Text(contact.info!.displayName.toString()),
            subtitle: Text(number
              //contact!.info!.phones!.elementAt(0).value.toString(),
              //getting the value of 1st available number of that contact
            ),
            leading: CircleAvatar(child: Text(contact.info!.initials()),),

          );
        },
      ),
    );
  }
}

