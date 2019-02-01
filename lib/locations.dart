import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Location data consists of a location-name and the corresponding LatLon as
/// retrieved from an api call.  As each location is looked up, the name/geocode
/// data is stored in SharedPrefs, which is then used for the next lookup instead
/// of another, repeated api call.

class LocationStore {

  static const _locationNamesKey = 'locationNames';
  Map<String, LatLng> _locationCache;

  /// Return the geocode for this location, or else null.
  /// If not in the cache, then lookup from open street map's api and save to
  /// shared prefs for next session.
  Future<LatLng> getLatLng(String name) async {
    if (_locationCache == null) {
      await _loadCache();
    }
    if (!_locationCache.containsKey(name)) {
      LatLng latLng = await _geocode(name);
      _locationCache[name] = latLng;
      // Also add to shared prefs for next call to getLatLng
      await _storeToPrefs(name, latLng);
    }
    return _locationCache[name];
  }

  /// Empty the cache and the shared prefs of all location geocodes.
  Future<void> clear() async {
    var prefs = await SharedPreferences.getInstance();
    var names = prefs.getStringList(_locationNamesKey);
    if (names != null) {
      for(var name in names) {
        print('LocationStore.clear: $name');
        prefs.remove(name);
      }
    }
    prefs.remove(_locationNamesKey);
    _locationCache = null;
  }

  /// Initialise the location cache with values from the SharedPref
  Future<void> _loadCache() async {
    print('LocationStore._loadCache');
    _locationCache = Map<String, LatLng>();
    var prefs = await SharedPreferences.getInstance();
    var names = prefs.getStringList(_locationNamesKey);
    if (names != null) {
      for(var name in names) {
        var list = prefs.getStringList(name);
        if (list != null && list.length == 2) {
          var lat = double.parse(list[0]);
          var lon = double.parse(list[1]);
          _locationCache[name] = LatLng(lat, lon);
          print('LocationStore._loadCache: cacheing geocode for $name');
        }
      }
    }
    print('LocationStore._loadCache finished');
  }

  /// Save the name and geocode to shared prefs.
  /// Overwrite the existing geocode with the new value.
  Future<void> _storeToPrefs(String name, LatLng latLng) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var names = prefs.getStringList(_locationNamesKey) ?? List<String>();
    if (!names.contains(name)) {
      names.add(name);
      prefs.setStringList(_locationNamesKey, names);
    }
    // If name was already in the list, just overwrite the lat-lon.
    prefs.setStringList(name, [
      latLng.latitude.toString(),
      latLng.longitude.toString(),
    ]);
    print('LocationStore._storeToPrefs: $name : ${latLng.toString()}');
  }

  Future<LatLng> _geocode(String location) async {
    // Ref: https://wiki.openstreetmap.org/wiki/Nominatim
    // eg. https://nominatim.openstreetmap.org/search?q=US\%20East\%20Coast&format=json&limit=1

    // Give osm some help to geocode these two names.
    if (location == 'US_West' || location == 'US_East') {
      location = location + '_Coast';
    }
    var req = 'https://nominatim.openstreetmap.org/search?q=' +
        location.replaceAll('_', '\\%20') + '&format=json&limit=1';

    var response = await http.get(req);
    if (response.statusCode != 200) {
      throw Exception('Failed to _geocode: ' + location);
    }
    Map<String, dynamic> parsedJson = json.decode(response.body)[0];

    print('LocationStore._geocode: retrieved geocode for $location');
    return LatLng(
      double.parse(parsedJson['lat']),
      double.parse(parsedJson['lon']),
    );
  }

}

