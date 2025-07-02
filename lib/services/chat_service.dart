import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  
  factory ChatService() {
    return _instance;
  }
  
  ChatService._internal();

  WebSocketChannel? _channel;
  final Map<String, StreamController<Map<String, dynamic>>> _messageControllers = {};
  String? _authToken;
  bool _isConnected = false;
  String? _currentUser;
  Timer? _pingTimer;

  bool get isConnected => _isConnected;
  
  // Khởi tạo kết nối WebSocket
  void initialize(String authToken, String currentUserId) {
    _authToken = authToken;
    _currentUser = currentUserId;
    
    final serverEndpoints = [
      'ws://localhost:8080/ws/chat',
      'ws://10.0.2.2:8080/ws/chat'
    ];
    
    // Thử từng endpoint
    _tryConnectToEndpoints(serverEndpoints);
  }
  
  void _tryConnectToEndpoints(List<String> endpoints, [int index = 0]) {
    if (index >= endpoints.length) {
      print('Không thể kết nối tới bất kỳ WebSocket endpoint nào');
      return;
    }
    
    print('Đang thử kết nối tới WebSocket endpoint ${endpoints[index]}');
    
    try {
      _connectToWebSocket(endpoints[index], 
        onSuccess: () {
          print('Kết nối WebSocket thành công tới ${endpoints[index]}');
        }, 
        onFailure: (error) {
          print('Lỗi kết nối WebSocket tới ${endpoints[index]}: $error');
          _tryConnectToEndpoints(endpoints, index + 1);
        }
      );
    } catch (e) {
      print('Ngoại lệ khi kết nối tới ${endpoints[index]}: $e');
      _tryConnectToEndpoints(endpoints, index + 1);
    }
  }

  void _connectToWebSocket(String url, {
    required Function onSuccess,
    required Function(dynamic) onFailure
  }) {
    try {
      final uri = Uri.parse(url);
      _channel = WebSocketChannel.connect(
        uri.replace(queryParameters: {'token': _authToken}),
      );
      
      _isConnected = true;
      onSuccess();
      
      // Thiết lập ping/pong để giữ kết nối
      _setupPingPong();
      
      // Lắng nghe tin nhắn từ server
      _channel!.stream.listen(
        (dynamic data) {
          _handleIncomingMessage(data);
        },
        onError: (error) {
          print('WebSocket error: $error');
          _isConnected = false;
          onFailure(error);
        },
        onDone: () {
          _isConnected = false;
          print('WebSocket bị ngắt kết nối');
          _notifyConnectionLost();
        },
      );
    } catch (e) {
      _isConnected = false;
      onFailure(e);
    }
  }
  
  void _setupPingPong() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        _channel?.sink.add(jsonEncode({'type': 'ping'}));
      } else {
        timer.cancel();
      }
    });
  }
  
  void _handleIncomingMessage(dynamic data) {
    try {
      final message = jsonDecode(data.toString());
      
      if (message['type'] == 'pong') {
        return; // Bỏ qua tin nhắn pong
      }
      
      final String conversationId = message['conversationId']?.toString() ?? '';
      
      if (conversationId.isNotEmpty) {
        final controller = _messageControllers[conversationId];
        if (controller != null && !controller.isClosed) {
          controller.add(message);
        }
      }
    } catch (e) {
      print('Lỗi khi xử lý tin nhắn: $e');
    }
  }
  
  void _notifyConnectionLost() {
    _messageControllers.forEach((_, controller) {
      if (!controller.isClosed) {
        controller.add({
          'type': 'disconnect',
          'message': 'Mất kết nối tới máy chủ'
        });
      }
    });
  }
  
  // Đăng ký nhận tin nhắn của một cuộc hội thoại
  Stream<Map<String, dynamic>> subscribeToConversation(String conversationId) {
    if (_messageControllers.containsKey(conversationId)) {
      return _messageControllers[conversationId]!.stream;
    }
    
    final controller = StreamController<Map<String, dynamic>>.broadcast();
    _messageControllers[conversationId] = controller;
    
    if (_isConnected) {
      _channel?.sink.add(jsonEncode({
        'type': 'subscribe',
        'conversationId': conversationId,
      }));
    } else {
      controller.add({
        'type': 'error',
        'message': 'WebSocket chưa kết nối'
      });
    }
    
    return controller.stream;
  }
  
  // Hủy đăng ký nhận tin nhắn
  void unsubscribeFromConversation(String conversationId) {
    if (_isConnected) {
      _channel?.sink.add(jsonEncode({
        'type': 'unsubscribe',
        'conversationId': conversationId,
      }));
    }
    
    final controller = _messageControllers[conversationId];
    if (controller != null && !controller.isClosed) {
      controller.close();
      _messageControllers.remove(conversationId);
    }
  }
  
  // Gửi tin nhắn
  Future<bool> sendMessage(String conversationId, String content) async {
    if (!_isConnected) {
      print('Không thể gửi tin nhắn: WebSocket chưa kết nối');
      return false;
    }
    
    try {
      final message = {
        'type': 'message',
        'conversationId': conversationId,
        'senderId': _currentUser,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      _channel?.sink.add(jsonEncode(message));
      return true;
    } catch (e) {
      print('Lỗi khi gửi tin nhắn: $e');
      return false;
    }
  }
  
  // Ngắt kết nối WebSocket
  void disconnect() {
    _pingTimer?.cancel();
    _channel?.sink.close();
    
    // Đóng tất cả các controller đang mở
    _messageControllers.forEach((_, controller) {
      if (!controller.isClosed) {
        controller.close();
      }
    });
    _messageControllers.clear();
    
    _isConnected = false;
    print('Đã ngắt kết nối WebSocket');
  }
  
  // Lấy danh sách tin nhắn của một cuộc hội thoại
  Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    if (_authToken == null) return [];
    
    try {
      final endpointsToTry = [
        'http://localhost:8080/api/conversations/$conversationId/messages',
        'http://10.0.2.2:8080/api/conversations/$conversationId/messages',
      ];
      
      for (String endpoint in endpointsToTry) {
        try {
          final response = await http.get(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $_authToken',
            },
          ).timeout(const Duration(seconds: 10));
          
          if (response.statusCode == 200) {
            final List<dynamic> data = jsonDecode(response.body);
            return data.map((msg) => {
              'id': msg['id'].toString(),
              'senderId': msg['senderId'].toString(),
              'content': msg['content'] ?? '',
              'timestamp': msg['timestamp'] ?? DateTime.now().toIso8601String(),
              'senderName': msg['senderName'] ?? 'Người dùng',
              'isMe': msg['senderId'].toString() == _currentUser,
            }).toList();
          }
        } catch (e) {
          print('Lỗi khi lấy tin nhắn từ $endpoint: $e');
        }
      }
      
      return [];
    } catch (e) {
      print('Lỗi khi lấy danh sách tin nhắn: $e');
      return [];
    }
  }
}
