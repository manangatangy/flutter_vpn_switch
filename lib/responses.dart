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

final homeBaseUrl = 'http://192.168.0.10:8080/vpns/';    // at home
final workBaseUrl = 'http://10.57.129.233:8080/vpns/';    // at work
final baseUrl = homeBaseUrl;

Future<GetLocationsResponse> requestGetLocations() async {
  final response = await http.get(baseUrl + 'locations');

  if (response.statusCode == 200) {
    GetLocationsResponse getLocations = GetLocationsResponse.fromJson(json.decode(response.body));
    return getLocations;
  } else {
    throw Exception('Failed to requestGetLocations');
  }
}

class GetLocationsResponse {
  final String resultCode;
  final List<String> locations;

  GetLocationsResponse({this.resultCode, this.locations});

  factory GetLocationsResponse.fromJson(Map<String, dynamic> parsedJson) {
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

Future<GetStatusResponse> requestGetStatus() async {
  final response = await http.get(baseUrl + 'status');

  if (response.statusCode != 200) {
    throw Exception('Failed to requestGetStatus');
  }
  return GetStatusResponse.fromJson(json.decode(response.body));
}

class GetStatusResponse {
  final String resultCode;
  final bool squidActive;
  final bool vpnActive;
  final String vpnLocation;

  GetStatusResponse({this.resultCode, this.squidActive, this.vpnActive, this.vpnLocation});

  factory GetStatusResponse.fromJson(Map<String, dynamic> parsedJson) {
    return GetStatusResponse(
      resultCode: parsedJson['resultCode'],
      squidActive: parsedJson['squidActive'],
      vpnActive: parsedJson['vpnActive'],
      vpnLocation: parsedJson['vpnLocation'],
    );
  }
}

Future<GetPingResponse> requestGetPing() async {
  final response = await http.get(baseUrl + 'ping/www.google.com');

  if (response.statusCode != 200) {
    throw Exception('Failed to requestGetPing');
  }
  return GetPingResponse.fromJson(json.decode(response.body));
}

class GetPingResponse {
  final String resultCode;
  final String target;

  GetPingResponse({this.resultCode, this.target});

  factory GetPingResponse.fromJson(Map<String, dynamic> parsedJson) {
    return GetPingResponse(
      resultCode: parsedJson['resultCode'],
      target: parsedJson['target'],
    );
  }
}

Future<GetCurrentResponse> requestGetCurrent() async {
  final response = await http.get(baseUrl + 'current');

  if (response.statusCode != 200) {
    throw Exception('Failed to requestGetCurrent');
  }
  return GetCurrentResponse.fromJson(json.decode(response.body));
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

Future<PostSwitchResponse> requestPostSwitch(String newLocation) async {
  final response = await http.post(baseUrl + 'switch/' + newLocation);

  if (response.statusCode != 200) {
    throw Exception('Failed to requestPostSwitch');
  }
  return PostSwitchResponse.fromJson(json.decode(response.body));
}

class PostSwitchResponse {
  final String resultCode;
  final String oldLocation;
  final String newLocation;

  PostSwitchResponse({this.resultCode, this.oldLocation, this.newLocation});

  factory PostSwitchResponse.fromJson(Map<String, dynamic> parsedJson) {
    return PostSwitchResponse(
      resultCode: parsedJson['resultCode'],
      oldLocation: parsedJson['oldLocation'],
      newLocation: parsedJson['newLocation'],
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