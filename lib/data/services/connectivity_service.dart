import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectivityService {
  final _controller =
      StreamController<bool>.broadcast(); // added stream so UI can update.

  ConnectivityService() {
    Connectivity().onConnectivityChanged.listen((status) {
      final online = status.any(
        (r) => [
          ConnectivityResult.wifi,
          ConnectivityResult.mobile,
          ConnectivityResult.ethernet,
          ConnectivityResult.vpn,
        ].contains(r),
      );

      _controller.add(online);
    });
  }

  Stream<bool> get onStatusChange => _controller.stream;

  Future<bool> get isOnline async {
    final status = await Connectivity().checkConnectivity();
    return status.any(
      (r) => [
        ConnectivityResult.wifi,
        ConnectivityResult.mobile,
        ConnectivityResult.ethernet,
        ConnectivityResult.vpn,
      ].contains(r),
    );
  }
}
