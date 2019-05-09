import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'friends.dart';

class Profile extends StatefulWidget
{
  FirebaseAuth _auth;

  Profile( FirebaseAuth a )
  {
    _auth = a;
  }

  @override
  ProfileState createState() => ProfileState( _auth );
}

class ProfileState extends State< Profile >
{
  FirebaseAuth _auth;
  FirebaseUser user;
  CollectionReference dbReference = Firestore.instance.collection( 'Users' );

  ProfileState( FirebaseAuth a )
  {
    _auth = a;
  }

  QuerySnapshot userSnapshot;

  Future< QuerySnapshot > initializeUser() async
  {
    user         = await _auth.currentUser();
    return dbReference.where( "UID", isEqualTo: user.uid ).getDocuments();
  }

  @override
  Widget build( BuildContext context )
  {
    TextEditingController nameFieldController = TextEditingController();
    String userName;

    return FutureBuilder(
      future: initializeUser(),
      builder: ( context, snapshot ) {
        if ( snapshot.hasData )
        {
          if ( snapshot.data != null )
          {
            userSnapshot = snapshot.data;
            userName = userSnapshot.documents.first.data[ "Name" ];

            return MaterialApp( 
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar( 
          centerTitle: false, 
          title: Text( "Profile" ),
          actions: <Widget>[
            IconButton(
              icon: Icon( Icons.person ),
              onPressed: () {
                Navigator.push( context, MaterialPageRoute( builder: ( context ) => Friends() ) );
              },
            ),
            IconButton(
              tooltip: "Edit Profile",
              icon: Icon( Icons.edit ),
              onPressed: () {
                showDialog( 
                  context: context,
                  builder: ( context ) {
                    return SimpleDialog(
                      children: <Widget>[
                        SizedBox(
                          child: Center(
                            child: Column(
                              children: <Widget>[
                                Text( 
                                  "Edit Username",
                                  style: TextStyle(
                                    fontSize: 28.0,
                                  ),
                                ),
                                Padding( padding: EdgeInsets.all( 10.0 ) ),
                                Padding( 
                                  padding: EdgeInsets.fromLTRB( 10.0, 0, 10.0, 20.0 ),
                                  child: TextField(
                                  controller: nameFieldController,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all( 20.0 ),
                                    hintText: "enter username",
                                  ),
                                ),
                                ),
                                MaterialButton(
                                  color: Colors.orange[ 300 ],
                                  onPressed: () {
                                    dbReference.document( userSnapshot.documents.first.documentID ).updateData( 
                                      < String, dynamic > {
                                        "Name" : nameFieldController.text
                                      }
                                    );
                                    Navigator.pop( context );
                                    setState( (){} );
                                  },
                                  child: Text( "Save" ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                );
              },
            ),
            IconButton(
              tooltip: "Sign Out",
              icon: Icon( Icons.exit_to_app ),
              onPressed: () {
                _auth.signOut();
                Navigator.popUntil( context, ModalRoute.withName( Navigator.defaultRouteName ) ); 
                Navigator.push( context, MaterialPageRoute( builder: ( context ) => LoginScreen() ) );
              },
            )
          ],
        ),
        body: Center(
          child: Container(
            child: Column( 
              children: <Widget>[
                Card(
                  elevation: 11.0,
                  child: SizedBox( 
                    height: 120.0,
                    child: ListTile(
                      leading: CircleAvatar(),
                      title: Text( userName ),
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
          else
          {
            return Center(
              child: Text( "FAILED TO LOAD PROFILE", style: TextStyle( color: Colors.white ) )
            );
          }
        }
        else
        {
          return Center(
            child: CircularProgressIndicator()
          );
        }
      },
    );
  }
}