import 'package:doctors_diary/screens/authenticate/registerScreen.dart';
import 'package:doctors_diary/screens/home/home_temp.dart';
import 'package:doctors_diary/shared/Loading.dart';
import 'package:doctors_diary/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyOTP = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController numberController = new TextEditingController();
  final TextEditingController otpController = new TextEditingController();

  var isLoading = false;
  var isResend = false;
  var isLoginScreen = true;
  var isOTPScreen = false;
  var verificationCode = '';

  @override
  void initState() {
    // TODO: implement initState
    if (_auth.currentUser != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => HomeTemp(),
        ),
            (route) => false,
      );
    }

    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isOTPScreen ? returnOTPScreen() : returnLoginScreen();
  }

  Widget returnLoginScreen() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Doctor's Journal",style: TextStyle(fontFamily: 'Raleway', fontSize: 25.0,),),

        backgroundColor: Colors.blue[900],

      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 100.0, horizontal: 50.0),
        child: Form(
          key:_formKey,
          child: Column(
            children: [
              SizedBox(height: 20.0,),
              TextFormField(
                //controller: phone,
                enabled: !isLoading,
                controller: numberController,
                keyboardType: TextInputType.phone,
                decoration: textInputDecoration.copyWith(
                    hintText: 'Enter mobile number'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter phone number';
                  }
                },


              ),
              SizedBox(height: 20.0),
              SizedBox(
                width: 100.0,
                child: !isLoading ? ElevatedButton(
                  onPressed: () async {
                    if (!isLoading) {
                      if (_formKey.currentState!
                          .validate()) {
                        displaySnackBar('Please wait...');
                        try{
                          await login();
                        }
                        catch(e){
                          print(e);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("#19 Unable to perform operation. Please check your connection")));
                        }
                      }
                    }
                  },
                  child: Text('Sign In'),
                  style: ElevatedButton.styleFrom(primary: Colors.pink),
                ) : Loading(),

              ),
              SizedBox(height: 10.0,),
              Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No Account?'),
                    TextButton(
                        onPressed: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      RegisterScreen()));
                        },
                        child: Text('Sign Up')
                    ),
                  ],
                ),
                



              )

            ],
          ),

        ),

      ),
    );


  }

  Widget returnOTPScreen(){
    return Scaffold(
      key: _scaffoldKey,
      appBar:AppBar(
        title: Text("Doctor's Journal",style: TextStyle(fontFamily: 'Raleway', fontSize: 25.0,),),

        backgroundColor: Colors.blue[900],

      ) ,
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20,horizontal: 50.0),
        child: Form(
          key: _formKeyOTP,
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                child: Text(
                  !isLoading?"Enter OTP from SMS":"Sending OTP code SMS",
                  textAlign: TextAlign.center,
                ),
              ),
              !isLoading?Container(
                padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 10.0),
                child: TextFormField(
                  enabled: !isLoading,
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  initialValue: null,
                  decoration: textInputDecoration.copyWith(hintText: 'Enter Otp'),
                  validator: (val){
                    if(val!.isEmpty){
                      return 'Please Enter OTP';
                    }
                  },

                ),

              ):Container(),
              !isLoading?Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: ElevatedButton(
                  onPressed: () async{
                    if(_formKeyOTP.currentState!.validate()){
                      // If the form is valid, we want to show a loading Snackbar
                      // If the form is valid, we want to do firebase signup...
                      setState(() {
                        isResend=false;
                        isLoading=true;
                      });
                      try{
                        await _auth.signInWithCredential(PhoneAuthProvider.credential(
                            verificationId: verificationCode,
                            smsCode: otpController.text.toString())).then((user) async => //sign in was success
                        {
                          if(user != null){
                            //store registration details in firestore database
                            setState(() {
                              isLoading = false;
                              isResend = false;
                            }),
                            Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => HomeTemp()),
                                  (route) => false,)
                          }
                        }).catchError((error) //check for '=>' if needed
                        {
                          setState((){
                            isLoading=false;
                            isResend=true;
                          });
                        });
                        setState(() {
                          isLoading=true;
                        });



                      }catch(e){
                        setState(() {
                          isLoading=false;
                        });

                      }
                    }

                  },
                  child: Text('Submit'),
                  style: ElevatedButton.styleFrom(primary: Colors.pink),

                ),
              ):Loading(),

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
                          try{
                            await login();


                          }
                          catch(e){
                            print(e);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("#18 Unable to perform operation. Please check your connection")));
                          }
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


  displaySnackBar(text) {
    final snackBar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future login() async {
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

  }
}
