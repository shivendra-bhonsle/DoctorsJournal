import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


String nextAppo = 'Not assigned';
String lastAppo = 'Not assigned';
String description = 'lorem ipsum';


class DatabaseService{
  final FirebaseAuth _auth = FirebaseAuth.instance;


  final String uid ;

  DatabaseService({required this.uid});




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

  Future createSubcollectionForAppointments({required String pid, required String name,required String mobile, required String appoDate, required String appoTime}) async{
    return  await FirebaseFirestore.instance.collection('users')
        .doc(uid)
        .collection('Appointments').add({
      'mobile':mobile,
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
    return _nextAppo.substring(0,10);
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

  Future toDeletePastAppointments() async{
    //DateTime today = DateTime.now();
    DateTime temp = DateTime.now();
    String hole = DateTime.now().toString().substring(0,10)+" 00:00:00Z";
    DateTime today = DateTime.parse(hole);
    String appoID = " ";
    await FirebaseFirestore.instance.collection('users').doc(uid)
        .collection('Appointments').get().then((value) {
          value.docs.forEach((element)  async {
            print("today = $today");
            temp = DateTime.parse(element.data()['appoDate'].toString());
            appoID = element.id.toString();
            if(temp.isBefore(today)){
              print("***today = $today");
              await FirebaseFirestore.instance.collection('users').doc(uid)
                  .collection('Appointments').doc(appoID).delete();
            }
          });
    });
  }



  }