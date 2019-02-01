import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_vpn_switch/locations.dart';
import 'package:flutter_vpn_switch/responses.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class LocationData {
  String text;
  bool doShow;
  bool isLoading;

  LocationData({
    this.text = 'N.A.',
    this.doShow = true,
    this.isLoading = false,
  });

  // TODO are these copy ctors really needed?
  factory LocationData.copy(LocationData src) {
    return LocationData(
      text: src.text,
      doShow: src.doShow,
      isLoading: src.isLoading,
    );
  }
}

enum VpnActivity {
  standby,
  starting,
  stopping,
}

class VpnBloc {

  final LocationStore _locationStore = LocationStore();
  LocationStore get locationStore => _locationStore;

  // This is the current available StatusData and Locations Data
  final StatusData _statusData = StatusData();
  final LocationData _actual = LocationData();
  final LocationData _pending = LocationData();

  final BehaviorSubject<StatusData>_statusDataSubject = BehaviorSubject<StatusData>();
  final BehaviorSubject<LocationData>_actualLocationDataSubject = BehaviorSubject<LocationData>();
  final BehaviorSubject<LocationData>_pendingLocationDataSubject = BehaviorSubject<LocationData>();
  final BehaviorSubject<VpnActivity>_vpnActivitySubject = BehaviorSubject<VpnActivity>();

  Stream<StatusData> get statusDataStream => _statusDataSubject.stream;
  Stream<LocationData> get actualLocationDataStream => _actualLocationDataSubject.stream;
  Stream<LocationData> get pendingLocationDataStream => _pendingLocationDataSubject.stream;
  Stream<VpnActivity> get vpnActivityStream => _vpnActivitySubject.stream;

  void dispose() {
    _statusDataSubject.close();
    _actualLocationDataSubject.close();
    _pendingLocationDataSubject.close();
    _vpnActivitySubject.close();
  }

  /// This is the location which is used as the iteration point for the left/right arrows.
  String get pendingLocation {
    return _pending.text;
  }

  /// Adjust the pending LocInfo member, so that the doShow flag is set
  /// if the pending-location text is different from the actual-location text
  /// or if the actual-location text is not available.
  LocationData adjustPending({bool pendingIsLoading = false}) {
    _pending.doShow = (_actual.text == 'N.A.' || _actual.text != _pending.text);
    _pending.isLoading = pendingIsLoading;
    return _pending;
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

    getStatus().then((response) {
      // Don't update pingStatus; it hasn't changed.
      _statusData.vpnStatus = response.vpnActive ? Status.ok : Status.nbg;
      _statusData.squidStatus = response.squidActive ? Status.ok : Status.nbg;
      _statusDataSubject.add(StatusData.copy(_statusData));

      _actual.text = response.vpnLocation;
      _actualLocationDataSubject.add(LocationData.copy(_actual));

      // It's may be possible to make this call inside refresh() however
      // I'm not convinced the vpn-server will be ok with that.
      fetchPending();
    });
  }

  /// Make request for pending location and use response to populate a value on the locations Stream.
  void fetchPending() {
    getPending().then((response) {
      _pending.text = response.pending;
      _pendingLocationDataSubject.add(LocationData.copy(adjustPending()));

      fetchPing();
    });
  }

  /// Make request for ping and use response to populate a value on the statusData Stream.
  void fetchPing() {
    // First reset pingStatus (others haven't changed: use current values).
    _statusData.pingStatus = Status.loading;
    _statusDataSubject.add(StatusData.copy(_statusData));

    getPing().then((response) {
      // Only update pingStatus; others haven't changed.
      _statusData.pingStatus = response.resultCode == 'OK' ? Status.ok : Status.nbg;
      _statusDataSubject.add(StatusData.copy(_statusData));
    });
  }

  /// Make request to set location and use response to populate a value on the locations Stream.
  void switchLocation(String newLocation) {
    // Notify that pending is loading.
    _pendingLocationDataSubject.add(LocationData.copy(adjustPending(pendingIsLoading: true)));

    postSwitchPending(newLocation).then((response) {
      _pending.text = response.newPendingLocation;
      _pendingLocationDataSubject.add(LocationData.copy(adjustPending()));
    });
  }

  void start() {
    _vpnActivitySubject.add(VpnActivity.starting);
    postStartStop(true).then((response) {
      // PostStartStopResponse
      fetchStatus();
      _vpnActivitySubject.add(VpnActivity.standby);
    });
  }

  void stop() {
    _vpnActivitySubject.add(VpnActivity.stopping);
    postStartStop(false).then((response) {
      fetchStatus();
      _vpnActivitySubject.add(VpnActivity.standby);
    });
  }
}
