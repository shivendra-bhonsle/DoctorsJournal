import 'package:doctors_diary/navigationBar/pages/Contacts/ContactDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doctors_diary/services/database.dart';
import 'AppContact.dart';
import 'package:flutter/material.dart';

//FOR LIST TILE OF EACH CONTACT

class ContactsList extends StatelessWidget {
  final List<AppContact?> contacts;
  Function() reloadContacts;
   ContactsList({Key? key, required this.contacts,required this.reloadContacts}) : super(key: key);

   FirebaseAuth _auth = FirebaseAuth.instance;




  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,//we use this as we are using a List inside column and both are scrollable
        itemCount: contacts.length, //condition for which to show
        itemBuilder: (context,index){
          AppContact? contact = contacts[index];
         String number="";
          contact!.info!.phones!.forEach((f) { number=f.value!;});
          return ListTile(
            onTap: () async{
              if(contact.info!.phones!.isNotEmpty){
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context)=>ContactDetails(
                      contact,
                      onContactUpdate: (AppContact _contact){
                        reloadContacts();


                      },
                      onContactDelete: (AppContact _contact){
                        reloadContacts();
                        Navigator.of(context).pop();//this will take it to contact list page again after contact is deleted


                      },
                    )));
              }
              else{//if a contact does not have a number

                  final snackBar = SnackBar(content: Text('Select a contact with a number'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);

              }
              await DatabaseService(uid: _auth.currentUser!.uid)
                  .createSubcollectionForPatientList(contact.info!.displayName.toString(),
                  contact.info!.phones!.elementAt(0).value.toString(), 50, 65, 'DD/MM/YYYY', 'dd/mm/yyyy', 'Lorem ipsum');

              await DatabaseService(uid: _auth.currentUser!.uid).getPatientByNameAndNumber(contact.info!.displayName.toString(), contact.info!.phones!.elementAt(0).value.toString());
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
