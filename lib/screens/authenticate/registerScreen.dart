import 'package:doctors_diary/screens/home/home_temp.dart';
import 'package:doctors_diary/shared/Loading.dart';
import 'package:doctors_diary/shared/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';




final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyOTP = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController nameController = new TextEditingController();
  final TextEditingController cellnumberController = new TextEditingController();
  final TextEditingController otpController = new TextEditingController();

  var isLoading = false;
  var isResend = false;
  var isRegister = true;
  var isOTPScreen = false;
  var verificationCode = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    nameController.dispose();
    cellnumberController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isOTPScreen ? returnOTPScreen() : registerScreen();
  }


  Widget registerScreen() {
    final node = FocusScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Doctor's Diary"),
        backgroundColor: Colors.indigo[900],

      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 100.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 20.0,),
              TextFormField(
                //controller: phone,
                enabled: !isLoading,
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: textInputDecoration.copyWith(
                    hintText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a name';
                  }
                },


              ),
              SizedBox(height: 10.0),
              TextFormField(
                //controller: phone,
                enabled: !isLoading,
                controller: cellnumberController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                decoration: textInputDecoration.copyWith(
                    hintText: 'Mobile Number'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a number';
                  }
                },


              ),
              SizedBox(height: 15.0,),
              SizedBox(
                width: 100.0,
                child: ElevatedButton(

                  onPressed: () {
                    if (!isLoading) {
                      if (_formKey.currentState!.validate()) {
                        // If the form is valid, we want to show a loading Snackbar
                        setState(() {
                          signUp();
                          isRegister = false;
                          isOTPScreen = true;
                        });
                      }
                    }
                  },
                  child: Text('Next'),
                  style: ElevatedButton.styleFrom(primary: Colors.pink),

                ),
              ),

            ],

          ),
        ),
      ),
    );
  }

  Widget returnOTPScreen({var isLoginScreen = false}) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Doctor's Diary"),
        backgroundColor: Colors.indigo[900],

      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50.0),
        child: Form(
          key: _formKeyOTP,
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                child: Text(
                  !isLoading ? "Enter OTP from SMS" : "Sending OTP code SMS",
                  textAlign: TextAlign.center,
                ),
              ),
              !isLoading ? Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                child: TextFormField(
                  enabled: !isLoading,
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  initialValue: null,
                  decoration: textInputDecoration.copyWith(
                      hintText: 'Enter Otp'),
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Please Enter OTP';
                    }
                  },

                ),

              ) : Container(),
              !isLoading ? Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: ElevatedButton(
                  onPressed: () async {

                    if (_formKeyOTP.currentState!.validate()) {
                      // If the form is valid, we want to show a loading Snackbar
                      // If the form is valid, we want to do firebase signup...
                      setState(() {
                        isResend = false;
                        isLoading = true;
                      });
                      try {
                        await _auth.signInWithCredential(
                            PhoneAuthProvider.credential(
                                verificationId: verificationCode,
                                smsCode: otpController.text.toString())).then((
                            user) async => //sign in was success
                        {
                          if(user != null){

                            //store registration details in firestore database
                            /*await _firestore.collection('users')
                                .doc(_auth.currentUser!.uid)
                                .set({
                              'name': nameController.text,
                              'mobile': cellnumberController.text.trim(),
                            },
                                SetOptions(
                                    merge: true)
                            ).then((value) =>
                            {
                              //then move to authorised area
                              setState(() {
                                isLoading = false;
                                isResend = false;
                              })
                            }
                            )*/
                            if(isLoginScreen == false){
                              setUserData()
                            },


                            setState(() {
                              isLoading = false;
                              isResend = false;
                            }),
                            Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      HomeTemp()),
                                  (route) => false,)
                          }
                        }).catchError((error) //check for '=>' if needed
                        {
                          setState(() {
                            isLoading = false;
                            isResend = true;
                          });
                        });
                        setState(() {
                          isLoading = true;
                        });
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  },
                  child: Text('Submit'),
                  style: ElevatedButton.styleFrom(primary: Colors.pink),

                ),
              ) : Loading(),

              isResend
                  ? Container(
                  margin: EdgeInsets.only(top: 40, bottom: 5),
                  child: Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 10.0),
                      child: new ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            isResend = false;
                            isLoading = true;
                          });
                          await signUp();
                        },
                        child: new Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 15.0,
                          ),
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Expanded(
                                child: Text(
                                  "Resend Code",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )))
                  : Column()


            ],
          ),
        ),
      ),
    );
  }
  //Commented for testing start

  Future setUserData() async {
    await _firestore.collection('users')
        .doc(_auth.currentUser!.uid)
        .set({
      'name': nameController.text,
      'mobile': cellnumberController.text.trim(),
    },
        SetOptions(
            merge: true)
    ).then((value) {
      //then move to authorised area
      setState(() {
        isLoading = false;
        isResend = false;
      });
    });
  }

  Future signUp() async {
    setState(() {
      isLoading = true;
    });
    var isValidUser = false;
    var phoneNumber = '+91' + cellnumberController.text.trim();
    await _firestore
        .collection('users')
        .where('mobile', isEqualTo: cellnumberController.text.trim())
        .get()
        .then((result) {
      if (result.docs.length > 0) {
        isValidUser = true;
      }
    });
    if(isValidUser==false){
      var verifyPhoneNumber = _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (phoneAuthCredential) {
            _auth.signInWithCredential(phoneAuthCredential).then((user) async =>
            {

              if (user!=null) //if user is not null
                {

                  //store registration details in firestore database
                  await _firestore
                      .collection('users')
                      .doc(_auth.currentUser!.uid)
                      .set({
                    'name': nameController.text.trim(),
                    'mobile': cellnumberController.text.trim()
                  }, SetOptions(
                      merge: true)) //if user accidentally registers for 2nd time i will merge
                      .then((value) =>
                  {
                    //then move to authorised area
                    setState(() {
                      isLoading = false;
                      isRegister = false;
                      isOTPScreen = false;

                      //navigate to is
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              HomeTemp(),
                        ),
                            (route) => false,
                      );
                    })
                  })
                      .catchError((onError) =>
                  {
                    debugPrint(
                        'Error saving user to db.' + onError.toString())
                  })
                }

            }

            );
          },
          //starts a verification process for given number and executes if number is verified
          verificationFailed: (FirebaseAuthException error) {
            debugPrint('Error Logging in: ' + error.message.toString());
            setState(() {
              isLoading = false;
            });
          },
          codeSent: (verificationId,
              [forResendingToken]) { //exceutes when firebase send the code
            setState(() {
              isLoading = false;
              verificationCode =
                  verificationId; //storing the code d=sent i.e verificationId into verificationCode
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            setState(() {
              isLoading = false;
              verificationCode = verificationId;
            });
          },
          timeout: Duration(
              seconds: 60) //starts a verification process for given phone number
      );
      await verifyPhoneNumber;
    }
    else{
      displaySnackBar("User already present");
      Navigator.of(context).pop();
    }



  }
  displaySnackBar(text) {
    final snackBar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

//Commented for testing end





/*void verify(var phoneNumber,{var isLoginScreen=false})async{

    var verifyPhoneNumber = _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (phoneAuthCredential) {
          _auth.signInWithCredential(phoneAuthCredential).then((user) async =>
          {

            if (user != null) //if user is not null
              {
                if(isLoginScreen==false){},
                //store registration details in firestore database
                await _firestore
                    .collection('users')
                    .doc(_auth.currentUser!.uid)
                    .set({
                  'name': nameController.text.trim(),
                  'mobile': cellnumberController.text.trim()
                }, SetOptions(
                    merge: true)) //if user accidentally registers for 2nd time i will merge
                    .then((value) =>
                {
                  //then move to authorised area
                  setState(() {
                    isLoading = false;
                    isRegister = false;
                    isOTPScreen = false;

                    //navigate to is
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            HomeTemp(),
                      ),
                          (route) => false,
                    );
                  })
                })
                    .catchError((onError) =>
                {
                  debugPrint(
                      'Error saving user to db.' + onError.toString())
                })
              }
          }

          );
        },
        //starts a verification process for given number and executes if number is verified
        verificationFailed: (FirebaseAuthException error) {
          debugPrint('Error Logging in: ' + error.message.toString());
          setState(() {
            isLoading = false;
          });
        },
        codeSent: (verificationId,
            [forResendingToken]) { //exceutes when firebase send the code
          setState(() {
            isLoading = false;
            verificationCode =
                verificationId; //storing the code d=sent i.e verificationId into verificationCode
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            isLoading = false;
            verificationCode = verificationId;
          });
        },timeout: Duration(seconds: 60) //starts a verification process for given phone number
    );
    await verifyPhoneNumber;
  }*/
/*
  Future login(TextEditingController numberController) async {
    setState(() {
      isLoading = true;
    });

    var phoneNumber = '+91' + numberController.text.trim();
    //first we will check if a user with this cell number exists
    var isValidUser = false;
    var number = numberController.text.trim();

    await _firestore
        .collection('users')
        .where('mobile', isEqualTo: number)
        .get()
        .then((result) {
      if (result.docs.length > 0) {
        isValidUser = true;
      }
    });
    if(isValidUser){
      //ok, we have a valid user, now lets do otp verification
      var verifyPhoneNumber = _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (phoneAuthCredential) {
          //auto code complete (not manually)
          _auth.signInWithCredential(phoneAuthCredential).then((user) async => {
            if (user != null)
              {
                //redirect
                setState(() {
                  isLoading = false;
                  isOTPScreen = false;
                }),
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => HomeTemp(),
                  ),
                      (route) => false,
                )
              }
          });
        },
        verificationFailed: (FirebaseAuthException error) {
          displaySnackBar('Validation error, please try again later');
          setState(() {
            isLoading = false;
          });
        },
        codeSent: (verificationId, [forceResendingToken]) {
          setState(() {
            isLoading = false;
            verificationCode = verificationId;
            isOTPScreen = true;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            isLoading = false;
            verificationCode = verificationId;
          });
        },
        timeout: Duration(seconds: 60),
      );
      await verifyPhoneNumber;
    } else {
      //non valid user
      setState(() {
        isLoading = false;
      });
      displaySnackBar('Number not found, please sign up first');


    }

  }*/


}

