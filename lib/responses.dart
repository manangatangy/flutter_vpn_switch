import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

//final homeBaseUrl = 'http://192.168.0.10:8080/vpns/';    // at home
//final workBaseUrl = 'http://10.57.129.172:8080/vpns/';    // at work
//final baseUrl = workBaseUrl;

Future<String> apiUrl(String path) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String baseIp = prefs.getString("IP-address");
  if (baseIp == null || baseIp.length == 0) {
    throw Exception('No IP-address defined\nplease go to config menu');
  }
  return 'http://' + baseIp + ':8080/vpns/' + path;
}

Future<http.Response> apiGet(String path) async {
  String url = await apiUrl(path);
  print("getting: $url");
  return await http.get(url);
}

Future<http.Response> apiPost(String path) async {
  String url = await apiUrl(path);
  print("posting: $url");
  return await http.post(url);
}

Future<GetLocationsResponse> getLocations() async {
  final response = await apiGet('locations');

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
  final response = await apiGet('status');

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
  final response = await apiGet('ping/www.google.com');

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
  final response = await apiGet('current');

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
  final response = await apiPost('switch/' + pendingLocation);

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

enum VpnAction {
  Start,
  Stop,
}

Future<PostStartStopResponse> postAction(VpnAction action) async {
  String text = (action == VpnAction.Start) ? 'start' : 'stop';
  final response = await apiPost(text);

  if (response.statusCode != 200) {
    throw Exception('Failed to postAction');
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
