import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static final _connectivity = Connectivity();

  static StreamSubscription? _subscription;

  static void listen(Function(bool isOnline) onChange) {
    _subscription?.cancel();

    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      final isOnline = result != ConnectivityResult.none;
      onChange(isOnline);
    });
  }

  static void dispose() {
    _subscription?.cancel();
  }
}