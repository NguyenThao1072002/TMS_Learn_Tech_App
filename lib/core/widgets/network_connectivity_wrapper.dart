import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tms_app/core/services/network_connectivity_service.dart';

class NetworkConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const NetworkConnectivityWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<NetworkConnectivityWrapper> createState() =>
      _NetworkConnectivityWrapperState();
}

class _NetworkConnectivityWrapperState
    extends State<NetworkConnectivityWrapper> {
  final NetworkConnectivityService _connectivityService =
      NetworkConnectivityService();
  bool _isPopupShowing = false;
  bool _isAppReady = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _initConnectivityListener();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Đánh dấu ứng dụng đã sẵn sàng khi context có sẵn
    _isAppReady = true;
  }

  Future<void> _initConnectivityListener() async {
    try {
      await _connectivityService.initialize();

      // Kiểm tra kết nối ban đầu sau khi khởi tạo
      final initialStatus = await Connectivity().checkConnectivity();
      print("Initial connectivity status: $initialStatus");

      // Nếu khởi đầu đã mất kết nối, hiển thị banner sau khi build xong
      if (initialStatus == ConnectivityResult.none) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _isAppReady) {
            _showNoConnectionBanner();
          }
        });
      }

      _connectivityService.connectivityStream.listen(
          (ConnectivityResult result) {
        print("🔌 Connectivity changed to: $result");
        if (!mounted) return;

        // Show banner when connection is lost
        if (result == ConnectivityResult.none) {
          if (!_isPopupShowing && mounted && _isAppReady) {
            print("🔴 Showing no connection banner");
            setState(() {
              _isPopupShowing = true;
            });

            // Đảm bảo context đã sẵn sàng trước khi hiển thị
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showNoConnectionBanner();
            });
          }
        } else if (_isPopupShowing) {
          // Hide banner when connection is restored
          print("🟢 Connection restored, hiding banner");
          _hideNoConnectionBanner();

          if (mounted) {
            setState(() {
              _isPopupShowing = false;
            });
          }
        }
      }, onError: (e) {
        print('❌ Lỗi khi lắng nghe kết nối mạng: $e');
      });
    } catch (e) {
      print('❌ Lỗi khởi tạo dịch vụ kết nối: $e');
    }
  }

  void _showNoConnectionBanner() {
    try {
      // Kiểm tra xem widget đã gắn context chưa
      if (!mounted || !_isAppReady) return;

      // Nếu đã có overlay, xóa nó trước
      _hideNoConnectionBanner();

      // Tạo overlay mới
      _overlayEntry = OverlayEntry(
        builder: (context) => Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: Colors.red.withOpacity(0.9),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.signal_wifi_off, color: Colors.white),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Không có kết nối mạng!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Vui lòng kiểm tra kết nối WiFi hoặc dữ liệu di động.',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: () async {
                      // Kiểm tra kết nối lại
                      final result = await Connectivity().checkConnectivity();
                      if (result != ConnectivityResult.none) {
                        _hideNoConnectionBanner();
                        if (mounted) {
                          setState(() {
                            _isPopupShowing = false;
                          });
                        }
                      }
                    },
                    child: Text('Thử lại'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Thêm overlay vào Overlay
      if (_overlayEntry != null) {
        print("📌 Inserting overlay entry");
        Overlay.of(context).insert(_overlayEntry!);
      }
    } catch (e) {
      print('❌ Không thể hiển thị thông báo mất kết nối: $e');
      _isPopupShowing = false;
    }
  }

  void _hideNoConnectionBanner() {
    if (_overlayEntry != null) {
      print("🗑️ Removing overlay entry");
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          widget.child,

          // Nút kiểm tra mất kết nối (chỉ hiển thị trong chế độ debug)
          if (ModalRoute.of(context)?.settings.name == '/')
            Positioned(
              bottom: 20,
              right: 20,
              child: Opacity(
                opacity: 0.7,
                child: FloatingActionButton(
                  heroTag: 'testNetworkBtn',
                  mini: true,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.wifi_off),
                  onPressed: () {
                    print("⚡ Test: Simulating connection lost");
                    _connectivityService.testConnectionLost();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hideNoConnectionBanner();
    super.dispose();
  }
}
