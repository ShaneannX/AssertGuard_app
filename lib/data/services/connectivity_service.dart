import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectivityService {
  static final instance = ConnectivityService._internal();
  ConnectivityService._internal() {
    _init();
  }

  final _controller = StreamController<bool>.broadcast();

  bool _currentStatus = false;
  bool get currentStatus => _currentStatus;

  void _init() {
    // LIST-BASED API
    Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet ||
          r == ConnectivityResult.vpn);

      _currentStatus = online;
      _controller.add(online);
    });

    // Initial status
    Connectivity().checkConnectivity().then((results) {
      final online = results.any((r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet ||
          r == ConnectivityResult.vpn);

      _currentStatus = online;
      _controller.add(online);
    });
  }

  Stream<bool> get onStatusChange => _controller.stream;

  Future<bool> isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet ||
        r == ConnectivityResult.vpn);
  }
}
