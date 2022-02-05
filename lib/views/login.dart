import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splitpay/views/home/home.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({ Key? key }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int currentState=0;
  final phoneController=TextEditingController();
  final otpController=TextEditingController();

  String _verificationId='';

  FirebaseAuth _auth=FirebaseAuth.instance;

  bool loading=false;

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  void signInWithPhoneAuthCredential(PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      loading=true;
    });
    try {
      final authCredential=await _auth.signInWithCredential(phoneAuthCredential);
      setState(() {
        loading=false;
      });
      if(authCredential.user!=null){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Home()));
      }
    } on FirebaseAuthException catch(e) {
      setState(() {
        loading=false;
      });
      print(e.message.toString());
      _scaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(e.message.toString())));
    }
  }

  getMobileFormWidget(){
    return Column(
      children: <Widget>[
        SizedBox(height: 100.0,),
        PhoneFieldHint(
          controller: phoneController,
        ),
        ElevatedButton(
          onPressed: () async {
            setState(() {
              loading=true;
            });
            await _auth.verifyPhoneNumber(
              phoneNumber: phoneController.text,
              timeout: Duration(seconds: 120),
              verificationCompleted: (phoneAuthCredential) async {
                setState(() {
                  loading=false;
                });
                signInWithPhoneAuthCredential(phoneAuthCredential);
              },
              verificationFailed: (verificationFailed) async {
                setState(() {
                  loading=false;
                });
                _scaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(verificationFailed.message.toString())));
              },
              codeSent: (verificationId, resendingToken) async {
                setState(() {
                  loading=false;
                  currentState = 1;
                  _verificationId=verificationId;
                });
              },
              codeAutoRetrievalTimeout: (verificationId) async{

              },
            );
          },
          child: Text('Send'),
        ),
      ],
    );
  }

  getOtpFormWidget(){
    return Column(
      children: <Widget>[
        SizedBox(height: 100.0,),
        PinFieldAutoFill(
          controller: otpController,
          decoration: UnderlineDecoration(
            textStyle: TextStyle(fontSize: 20, color: Colors.black),
            colorBuilder: FixedColorBuilder(Colors.black.withOpacity(0.3)),
          ),
          // currentCode: _code,
          onCodeSubmitted: (code) {
            print(code);
            print(otpController.text);
            PhoneAuthCredential phoneAuthCredential=PhoneAuthProvider.credential(verificationId: _verificationId, smsCode: otpController.text);
            signInWithPhoneAuthCredential(phoneAuthCredential);
          },
          onCodeChanged: (code) {
            if (code!.length == 6) {
              FocusScope.of(context).requestFocus(FocusNode());
            }
          },
        ),
        ElevatedButton(
          onPressed: () async {
            PhoneAuthCredential phoneAuthCredential=PhoneAuthProvider.credential(verificationId: _verificationId, smsCode: otpController.text);
            signInWithPhoneAuthCredential(phoneAuthCredential);
          },
          child: Text('Verify'),
        ),
      ],
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey=GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: loading?Center(child: CircularProgressIndicator(),): currentState==0?getMobileFormWidget():getOtpFormWidget(),
    );
  }
}
