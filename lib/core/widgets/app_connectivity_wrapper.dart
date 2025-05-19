import 'package:flutter/material.dart';
import 'package:tms_app/core/services/network_connectivity_service.dart';
import 'package:tms_app/core/DI/service_locator.dart';
import 'package:tms_app/core/widgets/network_connectivity_wrapper.dart';

/// Widget bao bọc ứng dụng với chức năng theo dõi kết nối mạng
class AppConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const AppConnectivityWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<AppConnectivityWrapper> createState() => _AppConnectivityWrapperState();
}

class _AppConnectivityWrapperState extends State<AppConnectivityWrapper> {
  // Khởi tạo service trực tiếp thay vì lấy từ GetIt
  final NetworkConnectivityService _connectivityService =
      NetworkConnectivityService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo dịch vụ kiểm tra kết nối
    _initConnectivityService();
  }

  Future<void> _initConnectivityService() async {
    await _connectivityService.initialize();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nếu dịch vụ chưa được khởi tạo, hiển thị màn hình loading
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Bọc ứng dụng với NetworkConnectivityWrapper để theo dõi kết nối
    return NetworkConnectivityWrapper(
      child: widget.child,
    );
  }
}
