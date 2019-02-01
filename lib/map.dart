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
  final GestureTapCallback onTapLeftArrow;
  final GestureTapCallback onTapRightArrow;

  CentrePanel({
    this.onTapLeftArrow,
    this.onTapRightArrow,
  });
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
            onTap: onTapLeftArrow,
          ),
          PendingLocationWidget(),
          ArrowButton(
              imageName: 'assets/arrow_right.png',
              onTap: onTapRightArrow,
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
//  var locationMap = Map<String, LatLng>();
  // Need a list that we can step through.
  var locationList = List<String>();

  mapCreated(GoogleMapController controller) async {
    mapController = controller;
    GetLocationsResponse getLocationsResponse = await getLocations();
    int count = 0;
    if (getLocationsResponse.resultCode == 'OK') {
      for (var name in getLocationsResponse.locations) {
        // temporary limit on markers
        if (++count > 7) {
          break;
        }

        var latLng = await VpnBlocProvider.of(context).locationStore.getLatLng(name);
        if (latLng != null) {
          locationList.add(name);
          mapController.addMarker(
            MarkerOptions(
              position: latLng,
              infoWindowText: InfoWindowText(name, null),
//            icon: BitmapDescriptor.fromAsset('images/flutter.png',),
            ),
          );
        }

//        OsmLatLon osmLatLon = await getOsmLatLon(location);
//        // TODO change from OsmLatLon to LatLon
//        locationMap[location] = LatLng(osmLatLon.lat, osmLatLon.lon);

//        mapController.animateCamera(
//          CameraUpdate.newLatLng(LatLng(osmLatLon.lat, osmLatLon.lon)),
//        );

      }
    }
    mapController.onMarkerTapped.add((Marker marker) {
      final vpnBloc = VpnBlocProvider.of(context);
      vpnBloc.switchLocation(marker.options.infoWindowText.title);
    });
  }

  void moveTo(String name) async {
    final vpnBloc = VpnBlocProvider.of(context);
    vpnBloc.switchLocation(name);
    mapController.animateCamera(
      CameraUpdate.newLatLng(
          await vpnBloc.locationStore.getLatLng(name)
      )
    );
  }

  int findCurrentLocationIndex() {
    String location = VpnBlocProvider.of(context).pendingLocation;
    for (var i = 0; i < locationList.length; i++) {
      if (location == locationList[i]) {
        return i;
      }
    }
    return -1;
  }

  void onTapLeftArrow() {
    int i = findCurrentLocationIndex();
    if (i != -1) {
      if (++i >= locationList.length) {
        i = 0;    // Wrap around to start
      }
      moveTo(locationList[i]);
    }
  }

  void onTapRightArrow() {
    int i = findCurrentLocationIndex();
    if (i != -1) {
      if (--i < 0) {
        i = locationList.length - 1;    // Wrap around to end
      }
      moveTo(locationList[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          onMapCreated: (GoogleMapController controller) => mapCreated(controller),
          options: GoogleMapOptions(
            mapType: MapType.satellite,
//            cameraPosition: CameraPosition(
//              target: LatLng(37.4219999, -122.0862462),
//            ),
          ),
        ),
        Positioned(
          top: 24.0 + 60.0,
          left: 0.0,
          right: 0.0,
          child: CentrePanel(
            onTapLeftArrow: onTapLeftArrow,
            onTapRightArrow: onTapRightArrow,
          ),
        ),
      ],
    );
  }
}
