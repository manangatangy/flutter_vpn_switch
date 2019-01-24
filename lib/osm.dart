import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

Future<OsmLatLon> requestGetOsmLatLon(String location) async {
  // Ref: https://wiki.openstreetmap.org/wiki/Nominatim

  if (location == 'US_West' || location == 'US_East') {
    location = location + '_Coast';
  }
  var req = 'https://nominatim.openstreetmap.org/search?q=' +
      location.replaceAll('_', '\\%20') + '&format=json&limit=1';
//  var req = 'https://nominatim.openstreetmap.org/search?q=US\%20East\%20Coast&format=json&limit=1';
//  https://nominatim.openstreetmap.org/search?q=US\%20East\%20Coast&format=json&limit=1

//  print('requesting: $req');
  final response = await http.get(req);

  if (response.statusCode == 200) {
    String body = response.body;
//    print('response.body: $body');
    dynamic decoded = json.decode(response.body);
//    print('decoded-type: ${decoded.runtimeType}');

    return OsmLatLon.fromJson(json.decode(response.body)[0]);
  } else {
    throw Exception('Failed to requestGetOsmLatLon: ' + location);
  }
}

class OsmLatLon {
  final double lat;
  final double lon;

  OsmLatLon({
    this.lat,
    this.lon,
  });

  factory OsmLatLon.fromJson(Map<String, dynamic> parsedJson) {
    var latLon = OsmLatLon(
      lat: double.parse(parsedJson['lat']),
      lon: double.parse(parsedJson['lon']),
    );
    return latLon;
  }
}

/*
https://nominatim.openstreetmap.org/search?q=US\%20East\%20Coast&format=json&limit=1

[
  {
    "place_id": "138338265",
    "licence": "Data © OpenStreetMap contributors, ODbL 1.0. https://osm.org/copyright",
    "osm_type": "way",
    "osm_id": "265859470",
    "boundingbox": [
      "39.9423251",
      "39.94241",
      "-75.0876419",
      "-75.0875328"
    ],
    "lat": "39.94236755",
    "lon": "-75.08758735",
    "display_name": "East Coast, Marlton Pike, Marlton, Camden, Camden County, New Jersey, 08105, USA",
    "class": "shop",
    "type": "convenience",
    "importance": 0.30100000000000005,
    "icon": "https://nominatim.openstreetmap.org/images/mapicons/shopping_convenience.p.20.png"
  }
]
 */
