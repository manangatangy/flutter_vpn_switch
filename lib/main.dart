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
//              mainAxisSize: MainAxisSize.max,
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
                Container(
                  width: 60.0,
//                  color: Colors.green,
                  child: Image(
                    image: AssetImage("assets/refresh.png"),
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
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

  Widget _locationTexts(bool doShow, String locationLabel, String locationText) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: !doShow ? Column() : Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                    mainAxisSize: MainAxisSize.max,
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
          ),                    ],
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

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
