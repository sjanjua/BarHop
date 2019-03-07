import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homepage.dart';

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

  String message = '';
  String verificationID;

  @override
  Widget build( BuildContext context )
  {
    return MaterialApp(
      title: "BarHop",
      theme: ThemeData( 
        brightness: Brightness.dark
      ),
      home: Builder(
        builder: ( context ) => Scaffold(
          appBar: appBar(),
          body:   loginScreen( context ),
        ),
      )
    );
  }

  Widget appBar()
  {
    return AppBar();
  }

  Widget loginScreen( BuildContext context )
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
              padding: EdgeInsets.fromLTRB( 0.0, 30.0, 0.0, 50.0 )
            ),
            Padding(
              padding: EdgeInsets.fromLTRB( 75.0, 0, 75.0, 0 ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "phone number"
                ),
                controller: emailController,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB( 75.0, 25.0, 75.0, 50.0 ),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "verification code"
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
              minWidth: 250.0,
              child: Text( "Send Verification Code" ),
            ),
            MaterialButton(
              onPressed: () {
                signInWithVerificationCode( passwordController.text )
                .then( ( user ) {
                  Navigator.push( context, MaterialPageRoute( builder: ( context ) => HomePage() ) );
                });
              },
              color: Colors.blueAccent,
              minWidth: 250.0,
              child: Text( "Sign In With Verification Code" )
            )
          ],
        ),
      ),
    );
  }

  void verifyPhoneNumber() async
  {
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

  Future< FirebaseUser > signInWithVerificationCode( String smsCode ) async
  {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      smsCode: passwordController.text,
      verificationId: verificationID
    );

      final FirebaseUser user        = await _auth.signInWithCredential( credential );
      final FirebaseUser currentUser = await _auth.currentUser();

      assert( user.uid == currentUser.uid );

      passwordController.text = '';
      print( 'sign in succeeded: $user' );

      return user;
  }
}

