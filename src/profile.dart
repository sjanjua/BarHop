import 'package:flutter/material.dart';

class Profile extends StatefulWidget
{

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State< Profile >
{
  @override
  Widget build( BuildContext context )
  {
    return MaterialApp( 
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar( centerTitle: true, title: Text( "Profile" ) ),
        body: Center(
          child: Container(
            child: Column( 
              children: <Widget>[
                Card(
                  elevation: 11.0,
                  child: SizedBox( 
                    height: 150.0,
                    child: ListTile(
                      leading: CircleAvatar(),
                      title: Text( "User Profile" ),
                      subtitle: Text( "user info goes here" ),
                    )
                  )
                ),
                Padding( padding: EdgeInsets. all( 10.0 ) ),
                Expanded(
                  child: ListView.builder( 
                  itemCount: 20,
                  itemBuilder: ( context, index ) {
                    return Card(
                      child: ListTile(
                      leading: Icon( Icons.star ),
                      title: Text( "Friend Activity" ),
                      subtitle: Text( "$index mins ago" ),
                    )
                    );
                  },
                )
                )
              ],
            )
          )
        )
      ),
    );
  }
}