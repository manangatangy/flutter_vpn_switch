import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_vpn_switch/responses.dart';
import 'package:rxdart/subjects.dart';

class VpnBlocProvider extends InheritedWidget {
  final VpnBloc vpnBloc;

  VpnBlocProvider({
    Key key,
    VpnBloc vpnBloc,
    Widget child,
  })  : vpnBloc = vpnBloc ?? VpnBloc(),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static VpnBloc of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(VpnBlocProvider) as VpnBlocProvider)
          .vpnBloc;
}

enum Status {
  unknown,
  loading,
  ok,
  nbg
}

class StatusData {
  Status vpnStatus;
  Status squidStatus;
  Status pingStatus;

  StatusData({
    this.vpnStatus = Status.unknown,
    this.squidStatus = Status.unknown,
    this.pingStatus = Status.unknown,
  });

  factory StatusData.copy(StatusData statusData) {
    return StatusData(
      vpnStatus: statusData.vpnStatus,
      squidStatus: statusData.squidStatus,
      pingStatus: statusData.pingStatus,
    );
  }
}

class LocationsData {
  String actualLocation;
  String pendingLocation;
  bool doShowPending;
  bool pendingIsLoading;

  LocationsData({
    this.actualLocation = 'N.A.',
    this.pendingLocation = '',
  }) {
    // The pending value will be shown only if the pendingLocation value
    // is different from the actual vpn location or the vpn location is empty.
    doShowPending = (actualLocation == 'N.A.' || actualLocation != pendingLocation);
    // A special value of pending is used to indicate that a switch call is underway.
    pendingIsLoading = (pendingLocation == 'LOADING');
  }

  factory LocationsData.copy(LocationsData locationsData) {
    return LocationsData(
      actualLocation: locationsData.actualLocation,
      pendingLocation: locationsData.pendingLocation,
    );
  }

}

class VpnBloc {

  // This is the current available StatusData and LocationsData
  final StatusData _statusData = StatusData();
  final LocationsData _locationsData = LocationsData();

  final BehaviorSubject<StatusData>_statusDataSubject = BehaviorSubject<StatusData>(
    seedValue: StatusData()
  );
  final BehaviorSubject<LocationsData>_locationsDataSubject = BehaviorSubject<LocationsData>(
      seedValue: LocationsData()
  );

  Stream<StatusData> get statusDataStream => _statusDataSubject.stream;
  Stream<LocationsData> get locationsDataStream => _locationsDataSubject.stream;

  void dispose() {
    _statusDataSubject.close();
    _locationsDataSubject.close();
  }

  /// Request the current location, status, and ping
  void refresh() {
    fetchStatus();
  }
  /// Make request for status and use response to populate a value on the statusData Stream.
  void fetchStatus() {
    // First reset status (pingStatus hasn't changed: use current value).
    _statusData.vpnStatus = Status.loading;
    _statusData.squidStatus = Status.loading;
    _statusDataSubject.add(StatusData.copy(_statusData));

    requestGetStatus().then((response) {
      print('getStatusResponse: ${response.squidActive}, ${response.vpnActive}, ${response.vpnLocation}');
      // Don't update pingStatus; it hasn't changed.
      _statusData.vpnStatus = response.vpnActive ? Status.ok : Status.nbg;
      _statusData.squidStatus = response.squidActive ? Status.ok : Status.nbg;
      _statusDataSubject.add(StatusData.copy(_statusData));
      _locationsData.actualLocation = response.vpnLocation;
      _locationsDataSubject.add(LocationsData.copy(_locationsData));

      // It's may be possible to make this call inside refresh() however
      // I'm not convinced the vpn-server will be ok with that.
      fetchCurrent();
    });
  }

  /// Make request for current location and use response to populate a value on the locations Stream.
  void fetchCurrent() {
    requestGetCurrent().then((response) {
      print('getPingResponse: ${response.resultCode}, ${response.current}');
      _locationsData.pendingLocation = response.current;
      _locationsDataSubject.add(LocationsData.copy(_locationsData));

      fetchPing();
    });
  }

  /// Make request for ping and use response to populate a value on the statusData Stream.
  void fetchPing() {
    // First reset pingStatus (others haven't changed: use current values).
    _statusData.pingStatus = Status.loading;
    _statusDataSubject.add(StatusData.copy(_statusData));

    requestGetPing().then((response) {
      print('getPingResponse: ${response.resultCode}, ${response.target}');
      // Only update pingStatus; others haven't changed.
      _statusData.pingStatus = response.resultCode == 'OK' ? Status.ok : Status.nbg;
      _statusDataSubject.add(StatusData.copy(_statusData));
    });
  }

  /// Make request to set current location and use response to populate a value on the locations Stream.
  void switchLocation(String newLocation) {
    _locationsData.pendingLocation = 'LOADING';
    _locationsDataSubject.add(LocationsData.copy(_locationsData));

    requestPostSwitch(newLocation).then((response) {
      print('postSwitchResponse: ${response.resultCode}, ${response.oldLocation}, ${response.newLocation}');
      _locationsData.pendingLocation = response.newLocation;
      _locationsDataSubject.add(LocationsData.copy(_locationsData));
    });
  }

/*

    GetCurrentResponse getCurrentResponse = await requestGetCurrentResponse();
    print('getCurrentResponse: ${getCurrentResponse.current}');


  final Cart _cart = Cart();

  final BehaviorSubject<List<CartItem>> _items =
  BehaviorSubject<List<CartItem>>(seedValue: []);

  final BehaviorSubject<int> _itemCount =
  BehaviorSubject<int>(seedValue: 0);

  final StreamController<CartAddition> _cartAdditionController =
  StreamController<CartAddition>();

  VpnBloc() {
    _cartAdditionController.stream.listen((addition) {
      int currentCount = _cart.itemCount;
      _cart.add(addition.product, addition.count);
      _items.add(_cart.items);
      int updatedCount = _cart.itemCount;
      if (updatedCount != currentCount) {
        _itemCount.add(updatedCount);
      }
    });
  }

  Sink<CartAddition> get cartAddition => _cartAdditionController.sink;

  Stream<int> get itemCount => _itemCount.stream;

  Stream<List<CartItem>> get items => _items.stream;

  void dispose() {
    _items.close();
    _itemCount.close();
    _cartAdditionController.close();
  }
   */
}
