import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget
{
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State< HomePage >
{
  GoogleMapController mapController;

  @override
  Widget build( BuildContext context )
  {
    return MaterialApp(
      theme: ThemeData(
         brightness: Brightness.dark
      ),
      home: Scaffold(
        body: GoogleMap(
          onMapCreated: onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng( 37.42796133580664, -122.085749655962 ),
            zoom: 11.0
          ),
        )
      )
    );
  }

  void onMapCreated( GoogleMapController controller )
  {
    mapController = controller;
  }
}