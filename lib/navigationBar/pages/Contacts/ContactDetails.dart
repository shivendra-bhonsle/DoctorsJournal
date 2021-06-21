import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    List<String> actions=<String>[
      'Edit',
      'Delete'
    ];

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


          ],

        ),
      ),
    );
  }
}
