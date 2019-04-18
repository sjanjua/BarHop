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
  int    forceResendToken;

  bool isUserAuthenticated = false;

  @override
  Widget build( BuildContext context )
  {
    getUser().then( ( user ) {
      if ( user != null )
      {
        setState( () {
          isUserAuthenticated = true;
        });
      }
    });

    return MaterialApp(
      title: "BarHop",
      theme: ThemeData( 
        brightness: Brightness.dark
      ),
      home: Builder(
        builder: ( context ) => Scaffold(
          body: isUserAuthenticated ? HomePage( _auth ) : ageVerification( context )
        ),
      )
    );
  }

  Future< FirebaseUser > getUser() async
  {
    FirebaseUser user = await _auth.currentUser(); 

    if ( user != null )
    {
      //print( "User ID: ${ user.uid }" );
      return user;
    }
    else
    {
      //print( "User ID: NONE, PLEASE SIGN IN" );
      return null;
    }
  }

  Widget appBar()
  {
    return AppBar();
  }

  Widget ageVerification(BuildContext context)
  {
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB( 50.0, 0.0, 50.0, 120.0 )
            ),
            Padding(
              padding: EdgeInsets.fromLTRB( 25.0, 5.0, 25.0, 5.0 ),
              child: Text(
              "By clicking this button, you agree that you are within the legal drinking age of your country and that you are responsible for any action while under the influence",
              style: TextStyle(
                fontSize: 25.0,
              ),
              textAlign: TextAlign.center,
            ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB( 75.0, 25.0, 75.0, 75.0 )
            ),
            MaterialButton(
              onPressed:(){
                Navigator.push( context, MaterialPageRoute( 
                  builder: ( context ) => loginScreen( context) ) 
                );
              },
              color: Colors.orange[300],
              minWidth: 250.0,
              child: Text( "I agree", style: TextStyle( color: Colors.black ) ),
            )
          ],
        ),
        ),
    );
  }
  
  Widget loginScreen( BuildContext context )
  {
    emailController.text = '6095054407';
    passwordController.text = '999999';

    return Material(
      child: createLoginScreen( context ),
    );
  }

  Widget createLoginScreen( BuildContext context ) => Center(
    child: Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 30.0)
        ),
        Container(
          width: 222.0,
          height: 185.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            image:DecorationImage(
              image:AssetImage('assets/barhoplogo.png'),
            )
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB( 0.0, 10.0, 0.0, 30.0 )
        ),
        Padding(
          padding: EdgeInsets.fromLTRB( 75.0, 0.0, 75.0, 0.0 ),
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
            verifyPhoneNumber();
          },
          color: Colors.orange[ 300 ],
          minWidth: 250.0,
          child: Text( "Send Verification Code", style: TextStyle( color: Colors.black ) ),
        ),
        MaterialButton(
          onPressed: () async {
            signInWithVerificationCode( passwordController.text )
            .then( ( user ) {
              Navigator.push( context, MaterialPageRoute( builder: ( context ) => HomePage( _auth ) ) );
            });
          },
          color: Colors.orange[300],
          minWidth: 250.0,
          child: Text( "Sign In With Verification Code", style: TextStyle( color: Colors.black ) )
        ),
      ],
    ),
  );

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
      
      verificationID   = verID;
      forceResendToken = forceResendingToken;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = ( String verID )
    {
      verificationID = verID;
    };

    await _auth.verifyPhoneNumber(
      phoneNumber:              '+1' + emailController.text,
      timeout:                  const Duration( seconds: 0 ),
      verificationCompleted:    completed,
      verificationFailed:       failed,
      codeSent:                 codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      forceResendingToken:      forceResendToken
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
