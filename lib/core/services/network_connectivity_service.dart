import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkConnectivityService {
  // Singleton instance
  static final NetworkConnectivityService _instance =
      NetworkConnectivityService._internal();
  factory NetworkConnectivityService() => _instance;
  NetworkConnectivityService._internal();

  // Connectivity instance
  final Connectivity _connectivity = Connectivity();

  // Controller for connectivity status stream
  final _connectivityController =
      StreamController<ConnectivityResult>.broadcast();

  // Stream to listen to connectivity changes
  Stream<ConnectivityResult> get connectivityStream =>
      _connectivityController.stream;

  // Current connectivity status
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  bool get isConnected => _connectionStatus != ConnectivityResult.none;

  // Initialize service
  Future<void> initialize() async {
    // Check initial connection status
    _connectionStatus = await _connectivity.checkConnectivity();
    _connectivityController.add(_connectionStatus);

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      print("Connectivity status changed: $result");
      _connectionStatus = result;
      _connectivityController.add(result);
    });
  }

  // Phương thức giả lập mất kết nối để kiểm tra
  void testConnectionLost() {
    print("Simulating connection lost");
    _connectionStatus = ConnectivityResult.none;
    _connectivityController.add(ConnectivityResult.none);
  }

  // Display network error popup
  void showNetworkErrorDialog(BuildContext context) {
    if (!isConnected) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.signal_wifi_off, color: Colors.red),
                SizedBox(width: 10),
                Text('Mất kết nối'),
              ],
            ),
            content: Text(
              'Không có kết nối mạng. Vui lòng kiểm tra kết nối WiFi hoặc dữ liệu di động và thử lại.',
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Thử lại'),
                onPressed: () async {
                  // Check connection again
                  final result = await _connectivity.checkConnectivity();
                  if (result != ConnectivityResult.none) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }

  // Dispose resources
  void dispose() {
    _connectivityController.close();
  }
}
