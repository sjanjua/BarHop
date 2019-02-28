import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget
{
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
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB( 75.0, 25.0, 75.0, 50.0 ),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: "password"
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {},
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