import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Ref: https://pub.dartlang.org/packages/google_maps_flutter
// And: https://medium.com/flutter-community/exploring-google-maps-in-flutter-8a86d3783d24
// I had to generate a new key following
// https://developers.google.com/maps/documentation/android-sdk/signup
// I tried to reuse the key from the flutter_catalog app (but failed).

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {},
          options: GoogleMapOptions(
            mapType: MapType.terrain,
          )
      ),
    );
  }
}
