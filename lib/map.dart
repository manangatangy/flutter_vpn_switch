import 'package:flutter/material.dart';
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

class CentrePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ArrowButton(
            imageName: 'assets/arrow_left.png',
            onTap: () {
            }
          ),
          PendingLocationWidget(),
          ArrowButton(
              imageName: 'assets/arrow_right.png',
              onTap: () {
              }
          ),
        ],
      ),
    );
  }
}

class ArrowButton extends StatelessWidget {
  final String imageName;
  final GestureTapCallback onTap;
  ArrowButton({
    this.imageName,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink.image(
        image: AssetImage(imageName),
        fit: BoxFit.cover,
        width: 60.0,
        child: InkWell(
          onTap: onTap,
          child: null,
        ),
      ),
    );
  }
}

class PendingLocationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vpnBloc = VpnBlocProvider.of(context);
    return StreamBuilder<LocationData>(
      stream: vpnBloc.pendingLocationDataStream,
      initialData: LocationData(),
      builder: (context, snapshot) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: !snapshot.data.doShow ? Column() : Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Text(
                'Pending location',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                child: (snapshot.data.isLoading) ?
                Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 100.0,
                      child: LinearProgressIndicator(),
                    )
                ) : Text(
                  snapshot.data.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

