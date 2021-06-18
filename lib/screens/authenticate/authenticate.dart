/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctors_diary/shared/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../home_temp.dart';




class Authenticate {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _formKeyOTP = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController otpController = new TextEditingController();

  var isLoading = false;
  var isResend = false;
  var isOTPScreen = false;
  var isRegister=true;
  var verificationCode = '';

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Widget returnOTPScreen(TextEditingController nameController,TextEditingController numberController,{var isLoginScreen = false}) {
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
                              setUserData(nameController,numberController)
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
              ) : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(
                          backgroundColor:
                          Theme
                              .of(context)
                              .primaryColor,
                        )
                      ].where((c) => c != null).toList(),
                    )
                  ]),
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
                          await signUp(nameController,numberController);
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

  Future<void> setUserData(TextEditingController nameController,TextEditingController cellnumberController) async {
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

  Future signUp(TextEditingController nameController,TextEditingController cellnumberController) async {
    setState(() {
      isLoading = true;
    });
    var phoneNumber = '+91' + cellnumberController.text.trim();
    var verifyPhoneNumber = _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (phoneAuthCredential) {
          _auth.signInWithCredential(phoneAuthCredential).then((user) async =>
          {

            if (user != null) //if user is not null
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
}
*/



