import 'package:flutter/widgets.dart';
import 'package:flutter_vpn_switch/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_vpn_switch/responses.dart';

// Ref: https://pub.dartlang.org/packages/google_maps_flutter
// And: https://medium.com/flutter-community/exploring-google-maps-in-flutter-8a86d3783d24
// I had to generate a new key following
// https://developers.google.com/maps/documentation/android-sdk/signup
// I tried to reuse the key from the flutter_catalog app (but failed).
// https://developers.google.com/maps/documentation/android-sdk/start

class VpnMap extends StatefulWidget {
  @override
  _VpnMapState createState() => _VpnMapState();
}

class _VpnMapState extends State<VpnMap> {
  GoogleMapController mapController;

  mapCreated(GoogleMapController controller) async {
    mapController = controller;
    GetLocationsResponse getLocationsResponse = await getLocations();
    int count = 2;
    if (getLocationsResponse.resultCode == 'OK') {
      for (var location in getLocationsResponse.locations) {
        // temporary limit on markers
        if (--count < 0) {
          break;
        }

        OsmLatLon osmLatLon = await getOsmLatLon(location);
        print('geocoded: $location = ${osmLatLon.lat}, ${osmLatLon.lon}');
        mapController.animateCamera(
          CameraUpdate.newLatLng(LatLng(osmLatLon.lat, osmLatLon.lon)),
        );
        mapController.addMarker(
          MarkerOptions(
            position: LatLng(osmLatLon.lat, osmLatLon.lon),
            infoWindowText: InfoWindowText(location, null),
//            icon: BitmapDescriptor.fromAsset('images/flutter.png',),
          ),
        );

      }
    }
    mapController.onMarkerTapped.add((Marker marker) {
      final vpnBloc = VpnBlocProvider.of(context);
      vpnBloc.switchLocation(marker.options.infoWindowText.title);
    });

  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) => mapCreated(controller),
      options: GoogleMapOptions(
        mapType: MapType.satellite,
        cameraPosition: CameraPosition(
          target: LatLng(37.4219999, -122.0862462),
        ),
      ),
    );
  }
}
