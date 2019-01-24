import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_vpn_switch/osm.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_vpn_switch/map.dart';
import 'package:flutter_vpn_switch/responses.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VPNSwitch',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Material(
          child: VpnPage(),
      ),
    );
  }
}

class VpnPage extends StatefulWidget {

  // The actual running or stopped state of the vpnswitcher is not tracked or recorded.
  // Instead, the status values; vpnActive, squidActive, and pingOk are held and shown
  // in the _status fields.
  // The vpnLocation returned from the statusResponse is used to show a _locationText
  // for 'VPN Exit Location'. This element will show "N.A." if the vpnLocation value is empty.
  // A second _locationText (for the 'Pending location') displays the response from the
  // currentLocation request.  This element will be shown only if the currentLocation value
  // is different from the vpnLocation or the vpnLocation is empty.

//  final Future<GetLocationsResponse> getLocationsResponse;


  @override
  VpnPageState createState() => VpnPageState();
}

class VpnPageState extends State<VpnPage> {

  GetLocationsResponse getLocationsResponse;
  GoogleMapController mapController;

  mapCreated(GoogleMapController controller) async {
    mapController = controller;
    getLocationsResponse = await requestGetLocationsResponse();
    int count = 3;
    if (getLocationsResponse.resultCode == 'OK') {
      for (var location in getLocationsResponse.locations) {

//        if (location != 'US_West' && location != 'US_East') {
//          continue;
//        }

        OsmLatLon osmLatLon = await requestGetOsmLatLon(location);
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


        if (count-- < 0) {
          break;
        }
      }
    }
    mapController.onMarkerTapped.add((Marker marker) {

    });
  }



  /*
        mapController.animateCamera(
  CameraUpdate.zoomTo(5.0),
);



mapController.animateCamera(
  CameraUpdate.newLatLngZoom(
    LatLng(37.4219999, -122.0862462),
    10.0, // Zoom factor
  ),
);

         */

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: GoogleMap(
            onMapCreated: (GoogleMapController controller) => mapCreated(controller),
            options: GoogleMapOptions(
              mapType: MapType.satellite,
              cameraPosition: CameraPosition(
                target: LatLng(37.4219999, -122.0862462),
              ),
            ),
          ),
        ),
        Positioned(
          top: 24.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            height: 70.0,
            color: Color(0x88424242),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _locationTexts(
                  true,
                  'VPN Exit Location',
                  'New York City',
                ),
                _locationTexts(
                  true,
                  'Pending Location',
                  'New York City',
                ),
                Material(
                  color: Colors.transparent,
                  child: Ink.image(
                    image: AssetImage("assets/refresh.png"),
                    fit: BoxFit.cover,
                    width: 60.0,
                    child: InkWell(
                      onTap: () {},
                      child: null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 80.0,
          left: 20.0,
          child: _borderButton('Stop', () {

          }),
        ),
        Positioned(
          bottom: 80.0,
          right: 20.0,
          child: _borderButton('Start', () {

          }),
        ),

        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            height: 60.0,
            color: Color(0x88424242),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _status('VPN', true),
                  _status('SQUID', false),
                  _status('PING', false),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _borderButton(String text, GestureTapCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(
          Radius.circular(12.0),
        ),
        border: Border.all(
          color: Colors.black26,
          style: BorderStyle.solid,
          width: 2.0,
        ),
        color: Color(0x88424242),
      ),
      width: 80.0,
      height: 40.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _locationTexts(bool doShow, String locationLabel, String locationText) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: !doShow ? Column() : Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            locationLabel,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
          Text(
            locationText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _status(String textString, bool isOk) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _statusText(textString),
        _statusIcon(isOk),
      ],
    );
  }

  Text _statusText(String textString) {
    return Text(
      textString,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18.0,
      ),
    );
  }

  Widget _statusIcon(bool isOk) {
    return Container(
      width: 60.0,
      color: Colors.transparent,
      child: Image(
        image: isOk ? AssetImage("assets/green_tick.png") : AssetImage("assets/red_cross.png"),
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  void initState() {
  }

}

// Using: https://flutter.io/docs/cookbook/networking/fetch-data  **this-is-good**
// https://flutter.io/docs/cookbook/networking/background-parsing  **this-too**

// and possibly https://stackoverflow.com/a/47075568/1402287
// (How work with progress indicator in flutter)
//and possible https://stackoverflow.com/questions/43550853/how-do-i-do-the-frosted-glass-effect-in-flutter
// (How do I do the “frosted glass” effect in Flutter?)
// which show https://gist.github.com/collinjackson/321ee23b25e409d8747b623c97afa1d5
// This https://medium.com/flutter-community/exploring-google-maps-in-flutter-8a86d3783d24
// shows how to animate the camera position for the maps, adding markers, zooming etc

// this https://grokonez.com/flutter/flutter-http-client-example-listview-fetch-data-parse-json-background
// is largely plagiarised from the cookbook, however it does have a small snippet of useful
// information regarding setting timeouts

// this https://medium.com/flutter-community/parsing-complex-json-in-flutter-747c46655f51
// has details about parsing, and could be handy when I get to the list parsing
// this https://medium.com/flutter-community/working-with-apis-in-flutter-8745968103e9
// by the same author is long winded and style is poor, but content is ok (just takes
// too much time to read all the fluff)

// at some point I may want to do a custom loading indicator animation, and this
// http://cogitas.net/custom-loading-animation-flutter/  could be handy

// I think i need a splash screen
// https://www.clounce.com/flutter/loading-screen-in-flutter
// this https://medium.com/@diegoveloper/flutter-splash-screen-9f4e05542548
// shows how to do it for android and ios
// this https://stackoverflow.com/questions/43879103/adding-a-splash-screen-to-flutter-appse
// also shows but part of it could be out of date.  The top rated answer seems in-of-date

