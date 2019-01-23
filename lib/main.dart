import 'package:flutter/material.dart';
import 'package:flutter_vpn_switch/map.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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

class VpnPage extends StatelessWidget {
  // The actual running or stopped state of the vpnswitcher is not tracked or recorded.
  // Instead, the status values; vpnActive, squidActive, and pingOk are held and shown
  // in the _status fields.
  // The vpnLocation returned from the statusResponse is used to show a _locationText
  // for 'VPN Exit Location'. This element will be hidden if the vpnLocation value is empty.
  // A second _locationText (for the 'Pending location') displays the response from the
  // currentLocation request.  This element will be shown only if the currentLocation value
  // is different from the vpnLocation or the vpnLocation is empty.

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        MapPage(),
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
}
