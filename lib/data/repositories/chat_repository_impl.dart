import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:tms_app/core/services/notification_webSocket.dart';
import 'package:tms_app/data/models/chat/chat_model.dart';
import 'package:tms_app/data/services/chat/chat_service.dart';
import 'package:tms_app/domain/repositories/chat_repository.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatService chatService;
  final StreamController<ChatMessageModel> _messageController =
      StreamController<ChatMessageModel>.broadcast();

  late StompClient _stompClient;
  bool _isConnected = false;
  Timer? _pingTimer;
  int _userId = 0;

  ChatRepositoryImpl({required this.chatService}) {
    _initWebSocket();
  }

  @override
  Stream<ChatMessageModel> get messageStream => _messageController.stream;

  Future<void> _initWebSocket() async {
    try {
      _userId = await _getUserId();

      // Tạo WebSocket URL
      final wsUrl = Constants.BASE_URL
              .replaceFirst('http://', 'ws://')
              .replaceFirst('https://', 'wss://') +
          '/ws';

      debugPrint('Connecting to WebSocket: $wsUrl');

      // Khởi tạo StompClient
      final socket = WebSocketChannel.connect(Uri.parse(wsUrl));
      _stompClient = StompClient(
        config: StompConfig(
          url: wsUrl,
          onConnect: (StompFrame connectFrame) {
            _onConnect(connectFrame);
          },
          onWebSocketError: (error) {
            debugPrint('WebSocket error: $error');
            _isConnected = false;
            _reconnect();
          },
          onDisconnect: (_) {
            debugPrint('WebSocket disconnected');
            _isConnected = false;
          },
        ),
      );

      // Kết nối
      _stompClient.activate();

      // Start ping timer
      _startPingTimer();
    } catch (e) {
      debugPrint('Error initializing WebSocket: $e');
    }
  }

  void _onConnect(StompFrame frame) {
    debugPrint('Connected to WebSocket');
    _isConnected = true;

    // Subscribe to user-specific channel
    _stompClient.subscribe(
      destination: '/user/$_userId/queue/messages',
      callback: (StompFrame frame) {
        try {
          final messageJson = json.decode(frame.body!);
          final message = ChatMessageModel.fromJson(messageJson);
          _messageController.add(message);
        } catch (e) {
          debugPrint('Error parsing message: $e');
        }
      },
    );
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isConnected) {
        _reconnect();
      } else {
        _sendPing();
      }
    });
  }

  void _sendPing() {
    try {
      if (_isConnected) {
        _stompClient.send(
          destination: '/app/ping',
          body: json.encode({
            'userId': _userId,
            'timestamp': DateTime.now().millisecondsSinceEpoch
          }),
        );
      }
    } catch (e) {
      debugPrint('Error sending ping: $e');
      _isConnected = false;
    }
  }

  void _reconnect() {
    debugPrint('Attempting to reconnect WebSocket...');
    try {
      _stompClient.deactivate();
      Future.delayed(const Duration(seconds: 2), () {
        _initWebSocket();
      });
    } catch (e) {
      debugPrint('Error reconnecting: $e');
    }
  }

  Future<int> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData != null) {
        final Map<String, dynamic> userMap = json.decode(userData);
        return userMap['id'] ?? 0;
      }
    } catch (e) {
      debugPrint('Error getting user ID: $e');
    }
    return 0;
  }

  @override
  Future<List<ChatConversationModel>> getConversations(int userId) async {
    return await chatService.getConversations(userId);
  }

  @override
  Future<ChatMessageModel> sendMessage(
      int fromId, int receiveId, String content) async {
    final message = await chatService.sendMessage(fromId, receiveId, content);
    return message;
  }

  @override
  Future<bool> markAsRead(int messageId) async {
    return await chatService.markAsRead(messageId);
  }

  @override
  Future<List<ChatMessageModel>> getMessages(
      String conversationId, String accountId) async {
    return await chatService.getMessages(conversationId, accountId);
  }

  @override
  Future<ChatConversationModel> createConversation(
      int fromId, int receiveId, String type) async {
    return await chatService.createConversation(fromId, receiveId, type);
  }

  void dispose() {
    _pingTimer?.cancel();
    _messageController.close();
    if (_isConnected) {
      _stompClient.deactivate();
    }
  }
}
