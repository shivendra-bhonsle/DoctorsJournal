import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctors_diary/models/patient.dart';
import 'package:doctors_diary/models/user.dart';
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

  Future createSubcollectionForPatientList(String name, String phoneno,
      int age, double weight,
      String nextAppo, String lastAppo,
      String description) async{
    return  await FirebaseFirestore.instance.collection('users')
        .doc(uid)
        .collection('PatientList')
        .add({
      //'pid' : pid,
      'name' : name,
      'phoneno' : phoneno,
      'age' : age,
      'weight' : weight,
      'nextAppo' : nextAppo,
      'lastAppo' : lastAppo,
      'description' : description
    }    );
  }
  
  //get patient info from subcollection
  getPatientByNameAndNumber(String name, String phoneno) async {
    return await FirebaseFirestore.instance.collection('users')
        .doc(uid).collection('PatientList').where("name", isEqualTo: name).get();
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