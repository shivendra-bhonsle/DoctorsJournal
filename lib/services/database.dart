import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

String nextAppo = 'DD/MM/YYYY';
String lastAppo = 'dd/mm/yyyy';
String description = 'lorem ipsum';


class DatabaseService{
  final FirebaseAuth _auth = FirebaseAuth.instance;


  final String uid ;
  //MyUser user = FirebaseAuth.instance.currentUser;

  DatabaseService({required this.uid});

  // final CollectionReference patientList = FirebaseFirestore.instance.collection('users')
  // .doc(user.uid).collection('patientList');

  Future createSubcollectionForPatientList(String name, String phoneno,          //if subcollection exists, only new doc is created
      String age,
      String nextAppo, String lastAppo,
      String description) async{
    return  await FirebaseFirestore.instance.collection('users')
        .doc(uid)
        .collection('PatientList').add({
      //'pid' : pid,
      'name' : name,
      'phoneno' : phoneno,
      'age' : age,
      'nextAppo' : nextAppo,
      'lastAppo' : lastAppo,
      'description' : description
    } );
  }

  Future createSubcollectionForAppointments(String pid, String name, String appoDate, String appoTime) async{
    return  await FirebaseFirestore.instance.collection('users')
        .doc(uid)
        .collection('Appointments').add({
      'pid' : pid,
      'name' : name,
      'appoDate' : appoDate,
      'appoTime' : appoTime
    } );
  }

  //get Document id of the patient
 Future<String> getDocIdOfPatient(String name, String phoneNo)async{
    String patientId = "Not fetched";
    //DocumentReference doc_ref = FirebaseFirestore.instance.collection('users').doc(uid).collection('PatientList').
    await FirebaseFirestore.instance.collection('users').doc(uid)
        .collection('PatientList')
        .where('name', isEqualTo: name)
        .where('phoneno', isEqualTo: phoneNo)
        .get().then((querySnapshot) {
      querySnapshot.docs.forEach((DocumentSnapshot element) {
        patientId = element.id;
        //print(patientId);
      });
    });

    return patientId;
  }

  //TODO get description from database
  Future<String?> getPatientDesc(String pid)async{
    String _description = "Tap to edit notes...";
    String uid = _auth.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid)
        .collection('PatientList') .doc(pid)
        .get().then((doc) => {
      print(doc.id),
      //print(doc.data()),
      _description = doc.data()!['description'].toString(),
      print(_description)

    }).catchError((e){
      print(e);
    });
    return _description;
  }

  //TODO get age from database
  Future<String?> getPatientAge(String pid)async{
    String _age = "Add";
    String uid = _auth.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid)
        .collection('PatientList') .doc(pid)
        .get().then((doc) => {
      print(doc.id),
      //print(doc.data()),
      _age = doc.data()!['age'].toString(),
      print(_age)

    }).catchError((e){
      print(e);
    });
    return _age;
  }

  //TODO get nextAppo from database
  Future<String?> getPatientNextAppo(String pid) async {
    String _nextAppo = "not assigned";
    String uid = _auth.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid)
        .collection('PatientList') .doc(pid)
        .get().then((doc) => {
      print(doc.id),
      //print(doc.data()),
      _nextAppo = doc.data()!['nextAppo'].toString(),
      print(_nextAppo)

    }).catchError((e){
      print(e);
    });
    return _nextAppo;
  }

  //TODO get lastAppo from database
  Future<String?> getPatientLastAppo(String pid)async{
    String _lastappo = "not assigned";
    String uid = _auth.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid)
        .collection('PatientList') .doc(pid)
        .get().then((doc) => {
      print(doc.id),
      //print(doc.data()),
      _lastappo = doc.data()!['lastAppo'].toString(),
      print(_lastappo)

    }).catchError((e){
      print(e);
    });
    return _lastappo;
  }

  //get snapshot of PatientList
  fetchAllPatents() async {
    bool doneOnce = true;             //just so that the nest loop doesn't print the result repeatedly
    return await FirebaseFirestore.instance.collection('users').get().then((QuerySnapshot querySnapshot){
      querySnapshot.docs.forEach((element) {
        if(doneOnce){
          doneOnce = false;
          FirebaseFirestore.instance.collection('users')
              .doc(uid).collection('PatientList')
              .get().then((querySnapshot){
            querySnapshot.docs.forEach((element) {
              print(element.data());
            });
          });
        }
      });
    });
  }

  fetchAllAppointments() async {
    return await FirebaseFirestore.instance.collection('users').doc(uid).collection('Appointments').get().then((QuerySnapshot querySnapshot){
      querySnapshot.docs.forEach((element) {
          print(element.id);
        });
      });
  }

  // get patient stream
  // Stream<Patient> get patients {
  //   return FirebaseFirestore.instance.collection('users')
  //       .doc(uid)
  //       .collection('PatientList').snapshots().map(_PatientListFromSnapshot)
  // }
  // }

  // patient form snapshot
  // List<Patient> _PatientListFromSnapshot(QuerySnapshot snapshot){
  //   return snapshot.hasdata? snapshot.docs.map((doc){
  //     return Patient(
  //         pid: doc.data()['pid'] ?? '',
  //         name: doc.data()['name'] ?? '',
  //         phoneno: phoneno,
  //         age: doc.data('age')?? 0,
  //         weight: weight,
  //         nextAppo: nextAppo,
  //         lastAppo: lastAppo,
  //         description: description
  //     );
  //   }).toList();
  }