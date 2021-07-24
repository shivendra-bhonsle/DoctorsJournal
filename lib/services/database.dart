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
    String _nextAppo = "Not assigned";
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
    String _lastappo = "Not assigned";
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
    String name="";
    String patId="";
    DateTime temp = DateTime.now();
    String hole = DateTime.now().toString().substring(0,10)+" 00:00:00Z";
    DateTime today = DateTime.parse(hole);
    String appoID = " ";
    String nextAppo_fetched="";
    await FirebaseFirestore.instance.collection('users').doc(uid)
        .collection('Appointments').get().then((value) {
          value.docs.forEach((element)  async {
            print("today = $today");
            patId=element.data()['pid'];
            name=element.data()['name'].toString();
            temp = DateTime.parse(element.data()['appoDate'].toString());
            appoID = element.id.toString();
            if(temp.isBefore(today)){
              print("***today = $today");
              await FirebaseFirestore.instance.collection('users').doc(uid)
                  .collection('Appointments').doc(appoID).delete().then((value) async => {

              await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                  .getPatientNextAppo(patId)
                  .then((value) => {
              nextAppo_fetched = value.toString()
              }),

                  //setting lastAppo to nextAppo
                  await FirebaseFirestore.instance.collection('users').doc(
                  FirebaseAuth.instance.currentUser!.uid).
              collection('PatientList').doc(patId).set(
                  {'lastAppo': nextAppo_fetched},
                  SetOptions(merge: true)),
                setNextAppoAfterDelete(name),
              });
            }
          });
    });
  }



  }

Future setNextAppoAfterDelete(String name) async{
  //to set nextAppo in "Patientlist->patient doc" to 'not assigned'
  String patID_ofPat_toBeDeleted = " ";
  String nextAppoStatus = "";
  DateTime minDt = DateTime.parse("2100-01-01 00:00:00Z");

  //get patDoc from Patientlist
  
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection("PatientList").
    where('name', isEqualTo: name).get().then((value) => {
      value.docs.forEach((element) {
        patID_ofPat_toBeDeleted = element.id.toString();
      })
    });
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection("Appointments")
        .where('name',isEqualTo: name)
        .get().then((value) => {
      value.docs.forEach((element) async {

        DateTime Dt = DateTime.parse(element.data()['appoDate']);
        if(Dt.isBefore(minDt)){
          minDt = Dt;
        }
      }),
      //print(_nextAppo),
      print("before setting nextAppo"),

      if(minDt == DateTime.parse("2100-01-01 00:00:00Z")){
        nextAppoStatus = "Not Assigned"
      }else{
        nextAppoStatus = minDt.toString()
      }

    }).then((value) async {
      await FirebaseFirestore.instance.collection('users').doc(
          FirebaseAuth.instance.currentUser!.uid).
      collection('PatientList').doc(patID_ofPat_toBeDeleted).set(
          {'nextAppo': nextAppoStatus},
          SetOptions(merge: true));
    });

  
  


}