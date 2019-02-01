import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

Future<OsmLatLon> getOsmLatLon(String location) async {
  // Ref: https://wiki.openstreetmap.org/wiki/Nominatim
  // eg. https://nominatim.openstreetmap.org/search?q=US\%20East\%20Coast&format=json&limit=1

  if (location == 'US_West' || location == 'US_East') {
    location = location + '_Coast';
  }
  var req = 'https://nominatim.openstreetmap.org/search?q=' +
      location.replaceAll('_', '\\%20') + '&format=json&limit=1';

//  print('requesting: $req');
  final response = await http.get(req);

  if (response.statusCode != 200) {
    throw Exception('Failed to getOsmLatLon: ' + location);
  }
//    String body = response.body;
//    print('response.body: $body');
//    dynamic decoded = json.decode(response.body);
//    print('decoded-type: ${decoded.runtimeType}');

  return OsmLatLon.fromJson(json.decode(response.body)[0]);
}

// TODO use LatLng instead of OsmLatLon

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
final workBaseUrl = 'http://10.57.129.172:8080/vpns/';    // at work
final baseUrl = workBaseUrl;

Future<GetLocationsResponse> getLocations() async {
  final response = await http.get(baseUrl + 'locations');

  if (response.statusCode != 200) {
    throw Exception('Failed to getLocations');
  }
  return GetLocationsResponse.fromJson(json.decode(response.body));
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

Future<GetStatusResponse> getStatus() async {
  final response = await http.get(baseUrl + 'status');

  if (response.statusCode != 200) {
    throw Exception('Failed to getStatus');
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

Future<GetPingResponse> getPing() async {
  final response = await http.get(baseUrl + 'ping/www.google.com');

  if (response.statusCode != 200) {
    throw Exception('Failed to getPing');
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

Future<GetPendingResponse> getPending() async {
  final response = await http.get(baseUrl + 'current');

  if (response.statusCode != 200) {
    throw Exception('Failed to getPending');
  }
  return GetPendingResponse.fromJson(json.decode(response.body));
}

class GetPendingResponse {
  final String resultCode;
  final String pending;

  GetPendingResponse({this.resultCode, this.pending});

  factory GetPendingResponse.fromJson(Map<String, dynamic> parsedJson) {
    return GetPendingResponse(
      resultCode: parsedJson['resultCode'],
      pending: parsedJson['current'],
    );
  }
}

Future<PostSwitchPendingResponse> postSwitchPending(String pendingLocation) async {
  final response = await http.post(baseUrl + 'switch/' + pendingLocation);

  if (response.statusCode != 200) {
    throw Exception('Failed to postSwitchPending');
  }
  return PostSwitchPendingResponse.fromJson(json.decode(response.body));
}

class PostSwitchPendingResponse {
  final String resultCode;
  final String oldPendingLocation;
  final String newPendingLocation;

  PostSwitchPendingResponse({this.resultCode, this.oldPendingLocation, this.newPendingLocation});

  factory PostSwitchPendingResponse.fromJson(Map<String, dynamic> parsedJson) {
    return PostSwitchPendingResponse(
      resultCode: parsedJson['resultCode'],
      oldPendingLocation: parsedJson['oldLocation'],
      newPendingLocation: parsedJson['newLocation'],
    );
  }
}

Future<PostStartStopResponse> postStartStop(bool doStart) async {
  final response = await http.post(baseUrl + (doStart ? 'start' : 'stop'));

  if (response.statusCode != 200) {
    throw Exception('Failed to postStartStop');
  }
  return PostStartStopResponse.fromJson(json.decode(response.body));
}


class PostStartStopResponse {
  final String resultCode;

  PostStartStopResponse({this.resultCode});

  factory PostStartStopResponse.fromJson(Map<String, dynamic> parsedJson) {
    return PostStartStopResponse(
      resultCode: parsedJson['resultCode'],
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