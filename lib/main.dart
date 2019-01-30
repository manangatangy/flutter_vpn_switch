import 'package:flutter/material.dart';
import 'package:flutter_vpn_switch/bloc.dart';
import 'package:flutter_vpn_switch/map.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return VpnBlocProvider(
      child: MaterialApp(
        title: 'VPNSwitch',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Material(
            child: VpnPage(),
        ),
      ),
    );
  }
}

class VpnPage extends StatelessWidget {

  // The actual running or stopped state of the vpnswitcher is not tracked or recorded.
  // Instead, the status values; vpnActive, squidActive, and pingOk are held and shown
  // in the _status fields.
  // The vpnLocation returned from the statusResponse is used to show a _locationText
  // for 'VPN Exit Location'. This element will show "N.A." if the vpnLocation value is empty.
  // A second _locationText (for the 'Pending location') displays the response from the
  // currentLocation request.  This element will be shown only if the currentLocation value
  // is different from the vpnLocation or the vpnLocation is empty.

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: VpnMap(),
        ),
        Positioned(
          top: 24.0,
          left: 0.0,
          right: 0.0,
          child: HeadingPanel(),
        ),
        Positioned(
          bottom: 80.0,
          left: 20.0,
          child: BorderedButton(
            label: 'Stop',
            onTap: () {

            },
          ),
        ),
        Positioned(
          bottom: 80.0,
          right: 20.0,
          child: BorderedButton(
            label: 'Start',
            onTap: () {

            },
          ),
        ),

        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: StatusPanel(),
        ),
      ],
    );
  }
}

class HeadingPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vpnBloc = VpnBlocProvider.of(context);
    return Container(
      height: 60.0,
      color: Color(0x88424242),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: LocationWidget(isActual: true),
          ),
          Expanded(
            flex: 1,
            child: LocationWidget(isActual: false),
          ),
          Material(
            color: Colors.transparent,
            child: Ink.image(
              image: AssetImage("assets/refresh.png"),
              fit: BoxFit.cover,
              width: 60.0,
              child: InkWell(
                onTap: () {
                  vpnBloc.refresh();
                },
                child: null,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class LocationWidget extends StatelessWidget {
  final bool isActual;

  LocationWidget({
    this.isActual,
  });

  @override
  Widget build(BuildContext context) {
    final vpnBloc = VpnBlocProvider.of(context);
    final Stream<LocationData> locInfoStream = isActual
        ? vpnBloc.actualLocationDataStream
        : vpnBloc.pendingLocationDataStream;
    final String label = isActual ? 'Current location' : 'Pending location';
    return StreamBuilder<LocationData>(
      stream: locInfoStream,
      initialData: LocationData(),
      builder: (context, snapshot) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: !snapshot.data.doShow ? Column() : Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Text(
                label,
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

class StatusPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vpnBloc = VpnBlocProvider.of(context);
    return Container(
      height: 60.0,
      color: Color(0x88424242),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<StatusData>(
          stream: vpnBloc.statusDataStream,
          initialData: StatusData(),
          builder: (context, snapshot) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              StatusIndicator(label: 'VPN', status: snapshot.data.vpnStatus),
              StatusIndicator(label: 'SQUID', status: snapshot.data.squidStatus),
              StatusIndicator(label: 'PING', status: snapshot.data.pingStatus),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusIndicator extends StatefulWidget {
  final String label;
  final Status status;

  StatusIndicator({
    this.label,
    this.status,
  });

  @override
  _StatusIndicatorState createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends State<StatusIndicator> {
  @override
  Widget build(BuildContext context) {
    Widget image;
    String asset;
    switch (widget.status) {
      case Status.unknown:
        asset = 'assets/yellow_question.png';
        break;
      case Status.ok:
        asset = 'assets/green_tick.png';
        break;
      case Status.nbg:
        asset = 'assets/red_cross.png';
        break;
      case Status.loading:
        image = Container(
          width: 40.0,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
        break;
    }
    if (asset != null) {
      image = Image(
        image: AssetImage(asset),
        fit: BoxFit.contain,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
        ),
        Container(
          width: 60.0,
          color: Colors.transparent,
          child: image,
        ),
      ],
    );
  }
}

class BorderedButton extends StatefulWidget {
  final String label;
  final GestureTapCallback onTap;

  BorderedButton({
    this.label,
    this.onTap,
  });

  @override
  BorderedButtonState createState() {
    return new BorderedButtonState();
  }
}

class BorderedButtonState extends State<BorderedButton> {
  @override
  Widget build(BuildContext context) {
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
          onTap: widget.onTap,
          child: Center(
            child: Text(
              widget.label,
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
}

// Checkout https://github.com/filiph/state_experiments.git
// for details about using streams/streambuilders

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

