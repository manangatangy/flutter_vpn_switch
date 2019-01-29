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
}

class VpnBloc {

  // This is the current available StatusData
  final StatusData _statusData = StatusData();

//  Status vpnStatus = Status.unknown;
//  Status squidStatus = Status.unknown;
//  Status pingStatus = Status.unknown;

  final BehaviorSubject<StatusData>_statusDataSubject = BehaviorSubject<StatusData>(
    seedValue: StatusData()
  );

  Stream<StatusData> get statusDataStream => _statusDataSubject.stream;

  void dispose() {
    _statusDataSubject.close();
  }

  /// Request the current location, status, and ping
  void refresh() {
    fetchStatus();
  }
  /// Make request for status and use response to populate a value on the statusData Stream.
  void fetchStatus() {
    // First reset status
    _statusData.vpnStatus = Status.loading;
    _statusData.squidStatus = Status.loading;
    // pingStatus hasn't changed: use current value.
    _statusDataSubject.add(StatusData.copy(_statusData));

    requestGetStatusResponse().then((response) => _handleStatusResponse(response));
  }

  void _handleStatusResponse(GetStatusResponse getStatusResponse) {
    print('getStatusResponse: ${getStatusResponse.squidActive}, ${getStatusResponse.vpnActive}, ${getStatusResponse.vpnLocation}');
    _statusData.vpnStatus = getStatusResponse.vpnActive ? Status.ok : Status.nbg;
    _statusData.squidStatus = getStatusResponse.squidActive ? Status.ok : Status.nbg;
    // pingStatus hasn't changed: use current value.
    _statusDataSubject.add(StatusData.copy(_statusData));
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
