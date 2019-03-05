import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget
{
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State< LoginScreen >
{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final dbReference = Firestore.instance.collection( 'Users' );

  TextEditingController emailController    = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  @override
  Widget build( BuildContext context )
  {
    return MaterialApp(
      title: "BarHop",
      theme: ThemeData( 
        brightness: Brightness.dark
      ),
      home: Scaffold(
        appBar: appBar(),
        body: loginScreen(),
      )
    );
  }

  Widget appBar()
  {
    return AppBar();
  }

  Widget loginScreen()
  {
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all( 50.0 )
            ),
            Text(
              "BarHop",
              style: TextStyle(
                fontSize: 30.0
              )
            ),
            Padding(
              padding: EdgeInsets.fromLTRB( 0.0, 100.0, 0.0, 50.0 )
            ),
            Padding(
              padding: EdgeInsets.fromLTRB( 75.0, 0, 75.0, 0 ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "email"
                ),
                controller: emailController,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB( 75.0, 25.0, 75.0, 50.0 ),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "password"
                ),
                controller: passwordController,
              ),
            ),
            MaterialButton(
              onPressed: () async {

                // dbReference.add({ 
                //   "Email"    : emailController.text,
                //   "Password" : passwordController.text
                // });

                verifyPhoneNumber();
              },
              color: Colors.blueAccent,
              minWidth: 150.0,
              child: Text( "Login" ),
            ),
            MaterialButton(
              onPressed: () {},
              color: Colors.blueAccent,
              minWidth: 150.0,
              child: Text( "Create Account" )
            )
          ],
        ),
      ),
    );
  }

  void verifyPhoneNumber() async
  {
    String message = '';
    String verificationID;

    final PhoneVerificationCompleted completed = ( FirebaseUser user )
    {
      setState( () {
        message = 'Verification succeeded: $user';
      });
    };

    final PhoneVerificationFailed failed = ( AuthException e )
    {
      setState( () {
        message = 'Verification failed...Code: ${e.code} --- Message: ${e.message}';
        print( message );
      });
    };

    final PhoneCodeSent codeSent = ( String verID, [ int forceResendingToken ] ) async
    {
      print( 'Check your phone for verification code...' );
      verificationID = verID;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = ( String verID )
    {
      verificationID = verID;
    };

    await _auth.verifyPhoneNumber(
      phoneNumber:              '+1' + emailController.text,
      timeout:                  const Duration( seconds: 5 ),
      verificationCompleted:    completed,
      verificationFailed:       failed,
      codeSent:                 codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }
}

