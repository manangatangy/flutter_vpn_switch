import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_vpn_switch/bloc.dart';
import 'package:flutter_vpn_switch/crashy.dart';
import 'package:flutter_vpn_switch/map.dart';
import 'package:flutter_vpn_switch/responses.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> returnAsFuture(String label, String value, bool ok) {
  String returnString = ok ? 'value-from-$label' : 'error-from-$label';
  Future<String> returnValue = ok ? Future.value(returnString) : Future.error(returnString);
  print("$label called with '$value' and will return type:'${returnValue.runtimeType}' with value:'$returnString'");
  return returnValue;
}

String returnAsString(String label, String value, bool ok) {
  String returnString = ok ? 'value-from-$label' : 'error-from-$label';
  String returnValue = returnString;
  if (ok) {
    print("$label called with '$value' and will return type:'${returnValue.runtimeType}' with value:'$returnString'");
    return returnValue;
  } else {
    print("$label called with '$value' and will throw type:'${returnValue.runtimeType}' with value:'$returnString'");
    throw returnValue;
  }
}

// Completing a Future (as a success) can be done by returning Future.value() or value; the successor
// (registered with then) will be passed the value in both cases.
// Completing a Future (as fail) can be done by returning Future.error() or throwing an error value;
// the successor, registered with catchError, or registered with then(onError:) will be passed the
// error value in both cases.

void mainFuture() {
  returnAsFuture('process1', 'valueA', true).then(
          (String value) => returnAsFuture('process2', value, true)
  ).then(
          (String value) => returnAsString('process3', value, true)
  ).then(
          (String value) => returnAsString('process4', value, false)
  ).then(
          (String value) => returnAsFuture('process5', value, true)
  ).catchError(
          (value) => returnAsString('catchError1', value, false)
  ).then(
          (String value) => returnAsString('process-final', value, true)
  ).catchError(
          (value) => returnAsString('catchError-final', value, true)
  );
}

//void main() => mainFuture();
//void main() => crashyMain();
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
            child: HomePage(),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vpnBloc = VpnBlocProvider.of(context);
    return Scaffold(
        drawer: DrawerMenu(),
        body: new Stack(
          children: <Widget>[
            VpnPage(),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                title: StreamBuilder<LocationData>(
                  stream: vpnBloc.actualLocationDataStream,
                  initialData: LocationData(),
                  builder: (context, snapshot) => Text(
                    snapshot.data.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                  ),
                ),
                actions: <Widget>[
                  IconButton(
                    icon: ImageIcon(
                        AssetImage("assets/refresh.png"),
                    ),
                    onPressed: () {
                      vpnBloc.refresh();
                    },
                  ),
                ],
                backgroundColor: Color(0x88424242),
                elevation: 0,
              ),
            )
          ],
        ),
    );
  }
}

class DrawerMenu extends StatefulWidget {

  DrawerMenu();

  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  final controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    // There are two ways to fetch the shared pref;
    // 1. Use the future API, (shown in TextField.onSubmitted code below) or
    // 2. Use await (this requires marking the function as async)
    // The await can't be applied to initState directly as it causes this runtime error:
    // The following assertion was thrown building _FocusScopeMarker:
    //I/flutter (12275): _DrawerMenuState.initState() returned a Future.
    //I/flutter (12275): State.initState() must be a void method without an `async` keyword.
    //I/flutter (12275): Rather than awaiting on asynchronous work directly inside of initState,
    //I/flutter (12275): call a separate method to do this work without awaiting it.
    loadSharedPref();
  }

  void loadSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    controller.text = prefs.getString("IP-address");
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vpnBloc = VpnBlocProvider.of(context);
    return new Drawer(
      child: new ListView(
        children: <Widget>[
          new ListTile(
            title: new Text("VPN Controller"),
          ),
          new Divider(),
          // ref: https://medium.com/flutter-community/a-deep-dive-into-flutter-textfields-f0e676aaab7a
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller,
              onSubmitted: (String ipAddress) {
                SharedPreferences.getInstance().then((SharedPreferences prefs) {
                  prefs.setString("IP-address", ipAddress);
                });
              },
              decoration: InputDecoration(
                labelText: "VPNswitch IP address",
              ),
            ),
          ),
          new Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlatButton(
              color: Colors.lightBlue,
              onPressed: () {
                SharedPreferences.getInstance().then((SharedPreferences prefs) {
                  prefs.remove("IP-address");
                });
                vpnBloc.locationStore.clear();
              },
              child: Text("Clear Location Cache"),
            ),
          ),
        ],
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
    final vpnBloc = VpnBlocProvider.of(context);
    return Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: VpnMap(),
        ),
        Positioned(
          bottom: 80.0,
          left: 20.0,
          child: BorderedButton(
            label: 'Stop',
            onTap: () {
              vpnBloc.stop(context);
            },
          ),
        ),
        Positioned(
          bottom: 80.0,
          right: 20.0,
          child: BorderedButton(
            label: 'Start',
            onTap: () {
              vpnBloc.start();
            },
          ),
        ),

        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: StatusPanel(),
        ),

        StreamBuilder<Indicator>(
          stream: vpnBloc.loadingIndicator,
          initialData: Indicator(isActive: false),
          builder: (context, snapshot) =>
          (!snapshot.data.isActive) ?
          Container() : LoadingIndicator(text: snapshot.data.text,),
        ),
        /// Use the errorIndicator stream to signal when error occurs.
        /// Note that the StreamBuilder.builder property must never return null.
        StreamBuilder<Indicator>(
          stream: vpnBloc.errorIndicator,
          initialData: Indicator(isActive: false),
          builder: (context, snapshot) {
            if (snapshot.data.isActive) {
               Future.delayed(Duration.zero, () => showAlert(context, snapshot.data.text));
            }
            return Container(width: 0.0, height: 0.0);
          },
        ),
      ],
    );
  }

  void showAlert(BuildContext context, message) async {
    /// showDialog's Future will complete once the dialog closes
    await showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: new Text("Error"),
              content: Text(message),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
    );
    VpnBlocProvider.of(context).clearError();
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

class LoadingIndicator extends StatelessWidget {
  final String text;
  LoadingIndicator({this.text});
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 3.0,
          sigmaY: 3.0,
        ),
        child: Container(
          color: Colors.black.withOpacity(0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 200.0,
                  height: 200.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 16,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: new Text(
                    text,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.yellow,
                    ),
                  ),
                ),
              ],
            ),
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

class BorderedButton extends StatelessWidget {
  final String label;
  final GestureTapCallback onTap;

  BorderedButton({
    this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
//        borderRadius: BorderRadius.all(
//          Radius.circular(12.0),
//        ),
        border: Border.all(
          color: Colors.black26,
          style: BorderStyle.solid,
          width: 2.0,
        ),
        color: Color(0x88424242),
      ),
      width: 80.0,
      height: 80.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
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
// and possible https://stackoverflow.com/questions/43550853/how-do-i-do-the-frosted-glass-effect-in-flutter
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

