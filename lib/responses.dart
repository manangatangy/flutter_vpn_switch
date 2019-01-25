import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

Future<OsmLatLon> requestGetOsmLatLon(String location) async {
  // Ref: https://wiki.openstreetmap.org/wiki/Nominatim
  // eg. https://nominatim.openstreetmap.org/search?q=US\%20East\%20Coast&format=json&limit=1

  if (location == 'US_West' || location == 'US_East') {
    location = location + '_Coast';
  }
  var req = 'https://nominatim.openstreetmap.org/search?q=' +
      location.replaceAll('_', '\\%20') + '&format=json&limit=1';

//  print('requesting: $req');
  final response = await http.get(req);

  if (response.statusCode == 200) {
//    String body = response.body;
//    print('response.body: $body');
//    dynamic decoded = json.decode(response.body);
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

Future<GetLocationsResponse> requestGetLocationsResponse() async {
  final response = await http.get('http://10.57.129.233:8080/vpns/locations');

  if (response.statusCode == 200) {
    GetLocationsResponse getLocations = GetLocationsResponse.fromJson(json.decode(response.body));
    return getLocations;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to requestGetLocationsResponse');
  }
}

class GetLocationsResponse {
  final String resultCode;
  final List<String> locations;

  GetLocationsResponse({this.resultCode, this.locations});

  factory GetLocationsResponse.fromJson(Map<String, dynamic> parsedJson) {
//    print('parsedJson: $parsedJson');
    var locationsFromJson = parsedJson['locations'];
    List<String> locations = new List<String>.from(locationsFromJson);
    var response = GetLocationsResponse(
      resultCode: parsedJson['resultCode'],
      locations: locations,
    );
    print('GetLocationsResponse.locations: ${response.locations}');
    return response;
  }
}

Future<GetCurrentResponse> requestGetCurrentResponse() async {
  final response = await http.get('http://10.57.129.233/vpns/current');

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    return GetCurrentResponse.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to requestGetCurrentResponse');
  }
}

class GetCurrentResponse {
  final String resultCode;
  final String current;

  GetCurrentResponse({this.resultCode, this.current});

  factory GetCurrentResponse.fromJson(Map<String, dynamic> parsedJson) {
    return GetCurrentResponse(
      resultCode: parsedJson['resultCode'],
      current: parsedJson['current'],
    );
  }
}


/*
    router.HandleFunc("/vpns/current", GetCurrent).Methods("GET")
    router.HandleFunc("/vpns/locations", GetLocations).Methods("GET")
    router.HandleFunc("/vpns/status", GetStatus).Methods("GET")
    router.HandleFunc("/vpns/ping/{target}", GetPing).Methods("GET")
    router.HandleFunc("/vpns/start", PostStart).Methods("POST")
    router.HandleFunc("/vpns/stop", PostStop).Methods("POST")
    router.HandleFunc("/vpns/switch/{newLocation}", PostSwitch).Methods("POST")

GetCurrent request...
{"resultCode":"OK","current":"UK_London"}

GetLocations request...
{"resultCode":"OK","locations":["AU_Melbourne","AU_Sydney","Brazil","CA_North_York","CA_Toronto","Denmark","Finland","France","Germany","Hong_Kong","India","Ireland","Israel","Italy","Japan","Mexico","Netherlands","New_Zealand","Norway","Romania","Singapore","Sweden","Switzerland","Turkey","UK_London","UK_Southampton","US_California","US_East","US_Florida","US_Midwest","US_New_York_City","US_Seattle","US_Silicon_Valley","US_Texas","US_West"]}

GetStatus request...
{"resultCode":"OK","squidActive":true,"vpnActive":true,"vpnLocation":"US_California"}

GetPing request...
{"resultCode":"OK","target":"www.google.com"}

PostStop request...
{"resultCode":"OK"}

PostStart request...
{"resultCode":"OK"}

PostSwitch request...
{"resultCode":"OK","oldLocation":"UK_London","newLocation":"aNewLocation"}

 */