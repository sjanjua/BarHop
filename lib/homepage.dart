import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart' as Places;
import 'package:location/location.dart' as Location;
import 'package:flutter/services.dart';
import 'login.dart';
import 'profile.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  FirebaseAuth _auth;

  HomePage(FirebaseAuth auth) {
    _auth = auth;
  }

  @override
  HomePageState createState() => HomePageState( _auth );
}

class HomePageState extends State< HomePage > {
  HomePageState( FirebaseAuth auth ) {
    _auth = auth;
  }

  FirebaseAuth        _auth;
  GoogleMap           map;
  GoogleMapController mapController;

  LatLng center;

  bool loadDetails = false;

  int searchRadius = 2500;

  Places.GoogleMapsPlaces places = Places.GoogleMapsPlaces(
      apiKey: 'AIzaSyCspDLMbkALY4Hj6Ba-qOb3cJMqS8WBs00'
  );

  List<Places.PlacesSearchResult> placesList = [];
  List< List< Places.Photo > >    photos     = [];
  List< String >                  distances  = [];
  List< double >                  ratings    = [];
  List< bool >                    isOpen     = [];

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  @override
  void initState()
  {
    super.initState();

    // initialize map
    // get current location
    //map = buildMap();
    // get nearby places
        // store nearby places
    //getNearbyPlaces( searchRadius );

    // refresh map
    //refreshMap( center );
  }

  @override
  Widget build( BuildContext context ) {
    return MaterialApp(  
      theme: ThemeData(brightness: Brightness.dark),
      home: Scaffold(
        appBar: AppBar( centerTitle: true, title: Text( "Nearby Bars" ) ),
        body: buildBody( context )
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
        markers: Set<Marker>.of( markers.values ) );

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
    photos.clear();
    distances.clear();
    ratings.clear();
    isOpen.clear();

    placesList.forEach((f) {

      String locationName = f.name;
      
      Marker marker = Marker( 
        markerId: MarkerId('$idVal'),
        position: LatLng(f.geometry.location.lat, f.geometry.location.lng),
        infoWindow: InfoWindow(
          title: "${f.name}",
          onTap: () {
            String mapsURL = "https://www.google.com/maps/dir/?api=1";

            mapsURL += '&destination=$locationName';

            canLaunch( mapsURL ).then( ( result ) {
              if ( result == true )
              {
                launch( mapsURL );
              }
            });
          }
        )
      ); 
      MarkerId id = MarkerId('${idVal++}');

      // setState( () {
        markers[id] = marker;
        //photos.add( f.photos ); 
        distances.add( f.vicinity );

        if ( f.openingHours != null )
        {
          isOpen.add( f.openingHours.openNow );
        }
        else
        {
          isOpen.add( false );
        }
        
        if ( f.rating == null )
        {
          ratings.add( 0.0 );
        }
        else
        {
          ratings.add( f.rating.toDouble() );
        }
        
      // });

      // markers.forEach((id, m) {
      //   print('Key: $id' + 'Marker: ${m.infoWindow.title}');
      // });
    });

    setState( () {
      print( "getNearbyPlaces() -> SetState()" );
    });

    //print( photos.toString() );
  }

  Widget loadDetailPanel( FirebaseAuth auth ) {
    //getNearbyPlaces( searchRadius );

    DetailPanel detailPanel = DetailPanel( markers, photos, distances, ratings, isOpen, auth );

    return detailPanel;
  }

  Widget buildBody( BuildContext context ) {
    return Stack(
      children: <Widget>[
        Container(
            child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
                Expanded( child: buildMap() )
          ],
        )),
        Align(
          alignment: Alignment.bottomRight,
          child: SizedBox(
            height: 150.0,
            width: 90.0,
            child: Padding(
            padding: EdgeInsets.all( 7.0 ),
            child: Column(
              children: <Widget>[
                FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Colors.redAccent,
                  child: Text( "Profile" ),
                  onPressed: () {
                    Navigator.push( context, MaterialPageRoute( builder: ( context ) => Profile( _auth ) ) );
                  },
                ),
                Padding( padding: EdgeInsets.all( 5.0 ) ),
                FloatingActionButton(
                  heroTag: null,
                  backgroundColor: Colors.redAccent,
                  child: Text( loadDetails ? "Map" : "List" ),
                  onPressed: () {
                    setState( () {

                      Navigator.push( context, MaterialPageRoute( builder: ( context ) => loadDetailPanel( _auth ) ) );

                      loadDetails = !loadDetails;
                    });
                  },
                ),
              ],
            ),
          )
          ), 
        ),
        Align(
          alignment: Alignment.topCenter,
          child: searchRadiusField(),
        ),
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
  List< List< Places.Photo > > photos = [];
  List< String > distances = [];
  List< double > ratings = [];
  List< bool > isOpen = [];

  FirebaseAuth _auth;

  DetailPanel( 
    Map<MarkerId, Marker> map, 
    List< List< Places.Photo > > p,
    List< String > d,
    List< double > r,
    List< bool > o,
    FirebaseAuth auth ) {
    markers = map;
    photos = p;
    distances = d;
    ratings = r;
    isOpen = o;
    _auth = auth;
  }

  @override
  DetailPanelState createState() => DetailPanelState(markers, photos, distances, ratings, isOpen, _auth );
}

class DetailPanelState extends State<DetailPanel> {
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  List< List< Places.Photo > > photos = [];
  List< String > distances = [];
  List< double > ratings = [];
  List< bool > isOpen = [];

  FirebaseAuth _auth;
  CollectionReference dbReference = Firestore.instance.collection( 'Users' );

  DetailPanelState(
    Map<MarkerId, Marker> m, 
    List< List< Places.Photo > > p,
    List< String > d,
    List< double > r,
    List< bool > o,
    FirebaseAuth auth ) {
    markers = m;
    photos = p;
    distances = d;
    ratings = r;
    isOpen = o;
    _auth = auth;
  }

  @override
  Widget build(BuildContext context) {
    List<MarkerId> markerIDs = markers.keys.toList();
    List<Marker> markersList = markers.values.toList();

    return ListView.builder(
        itemCount: markers.length,
        itemBuilder: (context, index) {
          String title = markersList[index].infoWindow.title;
          String snippet = markersList[ index ].markerId.toString();
          String distance = distances.elementAt( index );
          double rating   = ratings.elementAt( index );
          bool isOpenNow = isOpen.elementAt( index );

          return Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.all( 20.0 ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text( "$title"),
                    ],
                  ),
                  subtitle: Column(
                    children: <Widget>[
                      Text( "Rating: $rating" ),
                      Text( '$distance' ),
                      Text( isOpenNow ? "Open now" : "Closed now" ),
                      Padding(
                        padding: EdgeInsets.only( top: 15.0),
                        child: RaisedButton(
                          color: Colors.orange[ 300 ],
                          child: Text( "Check In" ),
                          onPressed: () async {
                            FirebaseUser user = await _auth.currentUser();

                            QuerySnapshot snapshot = await dbReference.where( "UID", isEqualTo: user.uid ).getDocuments();

                            dbReference.document( snapshot.documents.first.documentID ).updateData(
                              < String, dynamic >{
                                "CheckIn" : "$title"
                              }
                             );
                          },
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    String mapsURL = "https://www.google.com/maps/dir/?api=1";

                    mapsURL += '&destination=$title';

                    canLaunch( mapsURL ).then( ( result ) {
                      if ( result == true )
                      {
                        launch( mapsURL );
                      }
                    });
                  },
                ),
              ],
            ),
            elevation: 5.0,
            margin: EdgeInsets.all(10.0),
          );
        });
  }
}
