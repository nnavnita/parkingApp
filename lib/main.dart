import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

Future<Bay> fetchBay(int i) async {
  final response = await http
      .get('https://data.melbourne.vic.gov.au/resource/vh2v-4nfs.json');

  if (response.statusCode == 200) {
    return Bay.fromJson(jsonDecode(response.body), i);
  } else {
    throw Exception('Failed to load bay');
  }
}

class Bay {
  final String bayID;
  final String stMarkerID;
  final String status;
  final String lat;
  final String lon;
  factory Bay.fromJson(List<dynamic> json, int i) {
    return Bay(
      bayID: json[i]['bayID'],
      stMarkerID: json[i]['stMarkerID'],
      status: json[i]['status'],
      lat: json[i]['lat'],
      lon: json[i]['lon'],
    );
  }

  Bay({this.bayID, this.stMarkerID, this.status, this.lat, this.lon});
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Bay> futureBay;
  int i;
  LatLng _bayLocation;

  @override
  void initState() {
    super.initState();
    i = 0;
    futureBay = fetchBay(i);
  }

  Completer<GoogleMapController> _controller = Completer();
  
  final Set<Marker> _markers = {};

  MapType _currentMapType = MapType.normal;

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _onAddMarkerButtonPressed(String status, LatLng location) {
    var marker = BitmapDescriptor.defaultMarker;
    String titleString = "Unavailable";
    if (status == "Unoccupied") {
      marker = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      titleString = "Available";
    }
    setState(() {
      i= i+1;
      futureBay = fetchBay(i); 
      _bayLocation = location;
      _markers.add(Marker(
        markerId: MarkerId(_bayLocation.toString()),
        position: _bayLocation,
        infoWindow: InfoWindow(
          title: titleString,
        ),
        icon: marker,
      ));
    });
  }

  void _onCameraMove(CameraPosition position) {
    _bayLocation = position.target;
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),
        body: Center(
          child: FutureBuilder<Bay>(
            future: futureBay,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _bayLocation = LatLng(double.parse(snapshot.data.lat), double.parse(snapshot.data.lon));
                return Stack(
                  children: <Widget>[
                    GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _bayLocation,
                        zoom: 11.0,
                      ),
                      mapType: _currentMapType,
                      markers: _markers,
                      onCameraMove: _onCameraMove,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Column(
                          children: <Widget> [
                            FloatingActionButton(
                              onPressed: _onMapTypeButtonPressed,
                              materialTapTargetSize: MaterialTapTargetSize.padded,
                              backgroundColor: Colors.green,
                              child: const Icon(Icons.map, size: 36.0),
                            ),
                            SizedBox(height: 16.0),
                            FloatingActionButton(
                              onPressed: () => _onAddMarkerButtonPressed(snapshot.data.status, _bayLocation),
                              materialTapTargetSize: MaterialTapTargetSize.padded,
                              backgroundColor: Colors.green,
                              child: const Icon(Icons.add_location, size: 36.0),
                            )
                          ]
                        )
                      )
                    )
                  ]
                );
              } else {
                return Container();
              }
            }
          )
        )
      )
    );
  }
}
