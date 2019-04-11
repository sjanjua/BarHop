import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart' as Places;
import 'package:location/location.dart' as Location;
import 'package:flutter/services.dart';
import 'login.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  FirebaseAuth _auth;

  HomePage(FirebaseAuth auth) {
    _auth = auth;
  }

  @override
  HomePageState createState() => HomePageState(_auth);
}

class HomePageState extends State<HomePage> {
  HomePageState(FirebaseAuth auth) {
    _auth = auth;
  }

  FirebaseAuth _auth;
  GoogleMap map;
  GoogleMapController mapController;

  LatLng center;

  bool loadDetails = false;

  int searchRadius = 2500;

  Places.GoogleMapsPlaces places = Places.GoogleMapsPlaces(
      apiKey: 'AIzaSyCspDLMbkALY4Hj6Ba-qOb3cJMqS8WBs00');
  List<Places.PlacesSearchResult> placesList = [];

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  @override
  Widget build( BuildContext context ) {
    return MaterialApp(  
      theme: ThemeData(brightness: Brightness.dark),
      home: Scaffold(
        appBar: AppBar( centerTitle: true, title: Text( "Nearby Bars" ) ),
        body: buildBody()
      )
    );
  }

  void onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    await getCurrentLocation().then((latLng) {
      center = latLng;
    });

    getNearbyPlaces( searchRadius );

    refreshMap(center);
  }

  GoogleMap buildMap() {
    map = GoogleMap(
        onMapCreated: onMapCreated,
        myLocationEnabled: true,
        initialCameraPosition: CameraPosition(
            target: center == null ? LatLng( 40.058323, -74.4057 ) : center,
            zoom: 16.0),
        markers: Set<Marker>.of(markers.values));

    return map;
  }

  Future<LatLng> getCurrentLocation() async {
    Location.LocationData currentLocation;
    Location.Location locationService = Location.Location();

    try {
      currentLocation = await locationService.getLocation();

      LatLng center =
          LatLng(currentLocation.latitude, currentLocation.longitude);

      return center;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('PERMISSION DENIED');
      }

      currentLocation = null;
      return null;
    }
  }

  void refreshMap( LatLng location ) async {
    setState(() {
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: location == null ? LatLng(0.0, 0.0) : location, zoom: 16.0)));
    });
  }

  void getNearbyPlaces( int radius ) async {
    Places.Location location =
        Places.Location(center.latitude, center.longitude);

    final result = await places.searchNearbyWithRadius( location, radius, type: "bar" );
    
    placesList = result.results;

    int idVal = 0;
    
    markers.clear();

    placesList.forEach((f) {

      Marker marker = Marker(
          markerId: MarkerId('$idVal'),
          position: LatLng(f.geometry.location.lat, f.geometry.location.lng),
          infoWindow: InfoWindow(title: "${f.name}, ${f.types.first}")); 
      MarkerId id = MarkerId('${idVal++}');

      setState(() {
        markers[id] = marker;
      });

      markers.forEach((id, m) {
        print('Key: $id' + 'Marker: ${m.infoWindow.title}');
      });
    });
  }

  Widget loadDetailPanel() {
    getNearbyPlaces( searchRadius );

    DetailPanel detailPanel = DetailPanel( markers );

    return detailPanel;
  }

  Widget buildBody() {
    return Stack(
      children: <Widget>[
        Container(
            child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            loadDetails
                ? Expanded(child: loadDetailPanel())
                : Expanded(child: buildMap())
          ],
        )),
        Align(
            alignment: Alignment.bottomRight,
            child: FlatButton(
                color: Colors.black,
                child: Text( loadDetails ? "Map" : "List" ),
                onPressed: () {
                  setState(() {
                    getNearbyPlaces( searchRadius );

                    loadDetails = !loadDetails;
                  });
                })),
        Align(
          alignment: Alignment.topCenter,
          child: searchRadiusField(),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: FlatButton(
            color: Colors.black,
            child: Text( "Profile" ),
            onPressed: () {
              Navigator.push( context, MaterialPageRoute( builder: ( context ) => Profile() ) );
            }
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: FlatButton(
            color: Colors.black,
            child: Text( "Logout" ),
            onPressed: () {
              _auth.signOut();
              Navigator.pop( context ); 
              Navigator.push( context, MaterialPageRoute( builder: ( context ) => LoginScreen() ) );
            }
          )
        )
      ],
    );
  }

  Widget searchRadiusField()
  {
    TextEditingController controller = TextEditingController();

    return Padding(
      padding: EdgeInsets.fromLTRB( 75.0, 0.0, 75.0, 0.0 ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color.fromARGB( 100, 0, 20, 50 )
        ),
        textAlign: TextAlign.center,
        onEditingComplete: () {
          setState( () {
            print( "Editing Complete" );
            searchRadius = int.parse( controller.text );
            getNearbyPlaces( searchRadius );
            buildMap();
          });
        },
      )
    );
  }
}

class DetailPanel extends StatefulWidget {
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  DetailPanel(Map<MarkerId, Marker> map) {
    markers = map;
  }

  @override
  DetailPanelState createState() => DetailPanelState(markers);
}

class DetailPanelState extends State<DetailPanel> {
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  DetailPanelState(Map<MarkerId, Marker> m) {
    markers = m;
  }

  @override
  Widget build(BuildContext context) {
    List<MarkerId> markerIDs = markers.keys.toList();
    List<Marker> markersList = markers.values.toList();

    return ListView.builder(
        itemCount: markers.length,
        itemBuilder: (context, index) {
          String id = markerIDs[index].value.toString();
          String title = markersList[index].infoWindow.title;

          return Card(
            child: ListTile(
              contentPadding: EdgeInsets.all( 30.0 ),
              title: Text('Location: $title'),
              subtitle: Text('ID: $id'),
            ),
            elevation: 5.0,
            margin: EdgeInsets.all(10.0),
          );
        });
  }
}
