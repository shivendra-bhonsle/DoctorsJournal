import 'package:contacts_service/contacts_service.dart';
import 'package:doctors_diary/navigationBar/pages/Contacts/AppContact.dart';
import 'package:doctors_diary/shared/Loading.dart';
import 'package:flutter/material.dart';
import 'AppContact.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:collection/collection.dart';

import 'contactList.dart';
//MAIN PAGE FOR CONTACTS
class PatientList extends StatefulWidget {
  const PatientList({Key? key}) : super(key: key);

  @override
  _PatientListState createState() => _PatientListState();
}

class _PatientListState extends State<PatientList> {
  List<AppContact?> contacts=[];//this list will show all contacts
  List<AppContact?> contactsFiltered=[];//this list will show filtered contacts
  bool contactsLoaded = false;

  TextEditingController searchController=new TextEditingController(); //assigning a controller for search bar
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPermissions();//to get permissions fro the user as so as app initialises

  }
  String flattenPhoneNumber(String phoneStr){
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m){
      return m[0]=="+"?"+":""; //if first element is + keep it in flattenString else null

    }); //Replaces anything that is not a number with an empty string
  }
  getPermissions() async {
    if(await Permission.contacts.request().isGranted){//if permission is granted
        getAllContacts();//initialising method to get all contacts

        searchController.addListener(() {//whenever there is change in search bar filter the contacts
          filterContacts();
        });
    }
  }
  //List<AppContact?> _contacts=[];
  getAllContacts() async{
    /*List colors = [
      Colors.green,
      Colors.indigo,
      Colors.yellow,
      Colors.orange
    ];
    int colorIndex = 0;*/

    // Contact cntc;
    // cntc=(await ContactsService.openDeviceContactPicker()) as Contact;
    // _contacts.add(new AppContact(info: cntc,));
    List<AppContact?> _contacts = (await ContactsService.getContacts()).map((contact){//to get contacts from main contact app and map each contact
    /*Color baseColor = colors[colorIndex];
    colorIndex++;
    if (colorIndex == colors.length) {
      colorIndex = 0;
    }*/
      if( contact.givenName==null){
        return null;
      }
      return new AppContact(info: contact,);


      //return a object appContact
    }).toList();//convert to list*/
    print(_contacts);
    _contacts.removeWhere((element) => element==null);
    print(_contacts);

    setState(() {
      contacts=_contacts; //setting contacts to global variable
      contactsLoaded = true;
    });


  }

  filterContacts(){
    List<AppContact?> _contacts=[];
    _contacts.addAll(contacts);
    if(searchController.text.isNotEmpty){
      _contacts.retainWhere((contact) {//it removes all the items form the list which fails to pass the condition given
        String searchTerm=searchController.text.toLowerCase();
        String searchTermFlatten=flattenPhoneNumber(searchTerm);
        String contactName=contact!.info!.displayName!.toLowerCase();
        bool nameMatches=contactName.contains(searchTerm);
        if(nameMatches==true){
          return true;
        }
        if(searchTermFlatten.isEmpty){
          return false;
        }
        var phone=contact.info!.phones!.firstWhereOrNull((phn) {//give the first result whichever matches else null
          String phnFlatten=flattenPhoneNumber(phn.value.toString());
          return phnFlatten.contains(searchTermFlatten);
        });

        return phone != null;

        

      });


    }
    setState(() {
      contactsFiltered=_contacts;
    });


  }
  @override
  Widget build(BuildContext context) {
    bool isSearching=searchController.text.isNotEmpty;

    bool listItemsExist = (
        (isSearching == true && contactsFiltered.length > 0) ||
            (isSearching != true && contacts.length > 0));

    return Scaffold(
      appBar: AppBar(
        title: Text('Patient List'),
        centerTitle: true,
        backgroundColor: Colors.indigo[900],
      ),
      floatingActionButton: FloatingActionButton(//to add a new contact
        onPressed: () async{
          try {
            Contact contact=await ContactsService.openContactForm();//open new contact page in system contact app
            if(contact!=null){
              getAllContacts();//reload patientList after contact is added
            }
          } on FormOperationException catch (e) {
            // TODO
              switch(e.errorCode){
                case FormOperationErrorCode.FORM_OPERATION_CANCELED:
                case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
                case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
                  print(e.toString());
              }
          }

        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  border: new OutlineInputBorder(
                    borderSide: new BorderSide(
                      color: Theme.of(context).primaryColor
                    )
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).primaryColor,
                  ),

                ),
              ),
            ),

            contactsLoaded == true ?  // if the contacts have not been loaded yet
            listItemsExist == true ?  // if we have contacts to show
            ContactsList(
              reloadContacts: ()
              {getAllContacts();},
              contacts: isSearching == true ? contactsFiltered : contacts,
            ) : Container(
                padding: EdgeInsets.only(top: 40),
                child: Text(
                  isSearching ?'No search results to show' : 'No contacts exist',
                  style: TextStyle(color: Colors.grey, fontSize: 20),
                )
            ):Loading(),


          ],
        ),
      ),
    );
  }
}