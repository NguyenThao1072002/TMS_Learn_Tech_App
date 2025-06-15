import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:tms_app/data/models/notification_item_model.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationWebSocket {
  late StompClient stompClient;
  late WebSocketChannel channel;
  late StompClient _client;
  late StreamController<String> _streamController;
  late Stream<String> stream; // Stream of notifications
  final List<String> topics = ['general', 'notifications'];
  bool _isConnected = false;
  Timer? _pingTimer;
  final int _pingInterval = 30; // Ping every 30 seconds

  NotificationWebSocket({required this.stompClient});

  Future<int?> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData != null) {
        final Map<String, dynamic> userMap = json.decode(userData);
        return userMap['id'];
      }
    } catch (e) {
      debugPrint('Error getting user ID: $e');
    }
    return null;
  }

  // Mở kết nối WebSocket qua WSS (WebSocket Secure)
  void connect(String url) {
    _streamController = StreamController<String>.broadcast();
    channel = WebSocketChannel.connect(Uri.parse(url));
    stream = _streamController.stream; // Listen to the stream
    _isConnected = true;

    // Lắng nghe WebSocket và gửi dữ liệu vào StreamController
    channel.stream.listen((message) {
      _streamController
          .add(message as String); // Dữ liệu WebSocket sẽ được đẩy vào stream
      print("WebSocket received: $message");
    }, onError: (error) {
      print("WebSocket Error: $error");
      _reconnect(url);
    }, onDone: () {
      print("WebSocket connection closed");
      _reconnect(url);
    });

    // Start ping timer to keep connection alive
    _startPingTimer(url);
  }

  // void connectSocket(String userId) {
  //   // Khởi tạo StompClient
  //   final socket =
  //       WebSocketChannel.connect(Uri.parse('ws://192.168.1.156:8080/ws'));
  //   _client = StompClient(
  //     config: StompConfig(
  //       url: 'ws://192.168.1.156:8080/ws', // URL WebSocket của bạn
  //       onConnect: (frame) {
  //         _client.subscribe(
  //           destination: '/user/$userId/queue/notifications',
  //           callback: (frame) {
  //             // Khi nhận được tin nhắn từ WebSocket
  //             final messageBody = frame.body!;
  //             final newNotification =
  //                 NotificationItemModel.fromJson(json.decode(messageBody));
  //             print(messageBody);

  //             // Cập nhật danh sách thông báo và số lượng chưa đọc
  //             setState(() {
  //               _controller.notifications.insert(0, newNotification);
  //               _controller.unreadCount.value++;
  //             });
  //           },
  //         );
  //       },
  //       onWebSocketError: (error) {
  //         print('WebSocket error: $error');
  //       },
  //     ),
  //   );
  //   _client.activate();
  // }

  // Start a timer to send periodic pings
  void _startPingTimer(String url) {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(Duration(seconds: _pingInterval), (timer) {
      if (_isConnected) {
        _sendPing();
      } else {
        _reconnect(url);
      }
    });
  }

  // Send a ping message to keep the connection alive
  void _sendPing() {
    try {
      print("Sending ping to WebSocket");
      channel.sink.add(json.encode({
        'type': 'ping',
        'timestamp': DateTime.now().millisecondsSinceEpoch
      }));
    } catch (e) {
      print("Error sending ping: $e");
      _isConnected = false;
    }
  }

  // Public method to send a ping (can be called from outside)
  void sendPing() {
    _sendPing();
  }

  // Reconnect to WebSocket if connection is lost
  void _reconnect(String url) {
    if (!_isConnected) {
      print("Attempting to reconnect WebSocket...");
      try {
        close();
        Future.delayed(const Duration(seconds: 2), () {
          connect(url);
        });
      } catch (e) {
        print("Error reconnecting: $e");
      }
    }
  }

  // Trả về stream để có thể lắng nghe
  Stream<String> get notificationsStream => stream;

  // Đóng kết nối WebSocket khi không còn cần thiết
  void close() {
    _pingTimer?.cancel();
    _pingTimer = null;
    _isConnected = false;

    try {
      channel.sink.close();
      _streamController.close(); // Close StreamController
    } catch (e) {
      print("Error closing WebSocket: $e");
    }
  }

  void _subscribeToTopics(Function(String) onMessageReceived) {
    for (final topic in topics) {
      debugPrint('📩 Subscribing to /topic/$topic');
      stompClient.subscribe(
        destination: '/topic/$topic',
        callback: (StompFrame frame) {
          debugPrint('📬 Received message from /topic/$topic: ${frame.body}');
          if (frame.body != null) {
            _handleMessage(frame.body!, onMessageReceived);
          }
        },
      );
    }
  }

  void _subscribeToUserTopic(Function(String) onMessageReceived) {
    _getUserId().then((userId) {
      if (userId != null) {
        final userTopic = '/user/$userId/queue/notifications';
        debugPrint('📩 Subscribing to user-specific channel: $userTopic');
        stompClient.subscribe(
          destination: userTopic,
          callback: (StompFrame frame) {
            debugPrint('📬 Received user notification: ${frame.body}');
            if (frame.body != null) {
              _handleMessage(frame.body!, onMessageReceived);
            }
          },
        );
      }
    });
  }

  void _handleMessage(String message, Function(String) onMessageReceived) {
    try {
      debugPrint('🔍 Processing WebSocket message: $message');

      // Parse the notification directly like in React code
      final notificationData = json.decode(message);

      // Check if the message matches the format with readStatus
      if (message.contains('"notification":') &&
          message.contains('"readStatus":')) {
        final data = json.decode(message);
        if (data.containsKey('notification') &&
            data.containsKey('readStatus')) {
          final notification = data['notification'];
          final readStatus = data['readStatus'] ?? false;

          // Add read status to the notification object
          notification['status'] = !readStatus;

          // Send the notification object
          onMessageReceived(json.encode(notification));
          return;
        }
      }

      // If it's a direct notification object (API format)
      if (notificationData.containsKey('id') &&
          notificationData.containsKey('message') &&
          notificationData.containsKey('topic')) {
        // It's already in the correct format
        onMessageReceived(message);
        return;
      }

      // If we get here, try to use the message as is
      onMessageReceived(message);
    } catch (e) {
      debugPrint('❌ Error processing WebSocket message: $e');
      debugPrint('📄 Raw message: $message');

      // Try to extract notification from malformed JSON
      try {
        final startIndex = message.indexOf('{"id":');
        final endIndex = message.lastIndexOf('}');

        if (startIndex >= 0 && endIndex > startIndex) {
          final extractedJson = message.substring(startIndex, endIndex + 1);
          debugPrint('📋 Extracted JSON: $extractedJson');
          onMessageReceived(extractedJson);
        }
      } catch (extractError) {
        debugPrint('❌ Error extracting notification: $extractError');
      }
    }
  }

  void sendNotification(String message) {
    stompClient.send(
      destination: '/app/send-notification',
      body: message,
    );
  }

  void disconnect() {
    debugPrint('🔌 Disconnecting WebSocket');
    close();
  }
}
