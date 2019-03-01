import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatelessWidget
{

  final dbReference = Firestore.instance.collection( "Users" );

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
    TextEditingController emailController    = new TextEditingController();
    TextEditingController passwordController = new TextEditingController();

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
              onPressed: () {

                dbReference.add({ 
                  "Email"    : emailController.text,
                  "Password" : passwordController.text
                });

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
}

