import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Bay> fetchBay() async {
  final response = await http
      .get('https://data.melbourne.vic.gov.au/resource/vh2v-4nfs.json');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Bay.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load bay');
  }
}

class Bay {
  final String bayID;
  final String stMarkerID;
  final String status;
  final String lat;
  final String lon;

  // ignore: sort_constructors_first
  factory Bay.fromJson(List<dynamic> json) {
    return Bay(
      bayID: json[0]['bayID'],
      stMarkerID: json[0]['stMarkerID'],
      status: json[0]['status'],
      lat: json[0]['lat'],
      lon: json[0]['lon'],
    );
  }

  // ignore: sort_constructors_first
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

  @override
  void initState() {
    super.initState();
    futureBay = fetchBay();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<Bay>(
            future: futureBay,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data.bayID +
                    ', ' +
                    snapshot.data.stMarkerID +
                    ', ' +
                    snapshot.data.status +
                    ', ' +
                    snapshot.data.lat +
                    ', ' +
                    snapshot.data.lon);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
