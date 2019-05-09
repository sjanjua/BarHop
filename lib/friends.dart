import 'package:flutter/material.dart';

class Friends extends StatefulWidget
{
  @override 
  FriendsState createState() => FriendsState();
}

class FriendsState extends State< Friends >
{

  List< String > friends = [
    "123-456-7890",
    "849-283-2178",
    "899-155-2020",
    "555-555-5555",
    "101-585-1010",
    "856-632-8846",
    "902-456-8930",
  ];

  TextEditingController nameFieldController = TextEditingController();

  @override 
  Widget build( BuildContext context )
  {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text( "Friends" ),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon( Icons.add ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: ( context ) {
                    return SimpleDialog(
                      title: Text( "Add Friend" ),
                      children: <Widget>[
                        SizedBox(
                          child: Center(
                            child: Column(
                              children: <Widget>[
                                Padding( padding: EdgeInsets.all( 10.0 ) ),
                                Padding( 
                                  padding: EdgeInsets.fromLTRB( 10.0, 0, 10.0, 20.0 ),
                                  child: TextField(
                                  controller: nameFieldController,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all( 10.0 ),
                                    hintText: "enter phone number",
                                  ),
                                ),
                                ),
                                MaterialButton(
                                  color: Colors.orange[ 300 ],
                                  onPressed: () {
                                    Navigator.pop( context );
                                    setState( () {
                                      friends.add( nameFieldController.text );
                                    });
                                  },
                                  child: Text( "Save" ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Padding( padding: EdgeInsets.only( top: 20.0 ) ),
              Expanded(
                child: ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: ( context, index ) {
                    if ( friends.isNotEmpty )
                    {
                      return Card(
                        elevation: 11.0,
                        child: InkWell(
                          child: ListTile(
                            title: Text( "Friend $index" ),
                            subtitle: Text( "Checked in to bar $index minutes ago" ),
                            trailing: Text( friends[ index ] ),
                          ),
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: ( context ) {
                                return SizedBox(
                                  child: SimpleDialog(
                                    children: <Widget>[
                                      Center(
                                        child: Column(
                                          children: <Widget>[
                                            Padding( padding: EdgeInsets.only( top: 20.0 ) ),
                                            Text( 
                                              "Delete Friend?",
                                              style: TextStyle(
                                                fontSize: 24.0,
                                                fontWeight: FontWeight.bold,
                                              ), 
                                            ),
                                            Padding( padding: EdgeInsets.only( top: 20.0 ) ),
                                            MaterialButton(
                                              child: Text( "Delete" ),
                                              color: Colors.orange[ 300 ],
                                              onPressed: () {
                                                Navigator.pop( context );
                                                setState( () {
                                                  friends.removeAt( index );
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}