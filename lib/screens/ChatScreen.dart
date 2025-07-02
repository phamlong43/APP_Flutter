import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String userId;
  final bool isAdmin;
  final String username;

  const ChatScreen({
    super.key, 
    this.userId = '1',
    this.isAdmin = false,
    this.username = 'User',
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _login();
      await _fetchConversations();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi khởi tạo: $e';
      });
    }
  }

  // Đăng nhập để lấy token
  Future<void> _login() async {
    try {
      final endpointsToTry = [
        'http://localhost:8080/api/auth/login',
        'http://10.0.2.2:8080/api/auth/login',
      ];
      
      for (String endpoint in endpointsToTry) {
        try {
          print('Đang đăng nhập vào $endpoint...');
          
          final response = await http.post(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              "username": "user2",
              "password": "admin"
            }),
          ).timeout(const Duration(seconds: 10));
          
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['token'] != null) {
              setState(() {
                _authToken = data['token'];
              });
              
              print('Đăng nhập thành công, token: ${_authToken!.substring(0, 20)}...');
              return;
            }
          } else {
            print('Đăng nhập thất bại: ${response.statusCode} - ${response.body}');
          }
        } catch (e) {
          print('Lỗi khi đăng nhập vào $endpoint: $e');
        }
      }
      
      // Nếu không đăng nhập được, hiển thị lỗi
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không thể đăng nhập. Vui lòng kiểm tra kết nối mạng hoặc thông tin đăng nhập.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi đăng nhập: $e';
      });
    }
  }

  // Lấy danh sách cuộc trò chuyện
  Future<void> _fetchConversations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final endpointsToTry = [
        'http://localhost:8080/api/chat/conversations/${widget.userId}',
        'http://10.0.2.2:8080/api/chat/conversations/${widget.userId}',
      ];
      
      bool success = false;
      
      for (String endpoint in endpointsToTry) {
        try {
          print('Đang lấy danh sách hội thoại từ $endpoint...');
          
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
            
            // Kiểm tra xem data có phải là danh sách các đối tượng chat không
            if (data.isNotEmpty && data[0].containsKey('sender')) {
              // Trường hợp API trả về tin nhắn cuối cùng với từng người dùng khác
              // Tạo một Map để lưu trữ hội thoại mới nhất cho mỗi người dùng
              final Map<String, Map<String, dynamic>> latestMessagesByUser = {};
              
              for (var message in data) {
                // Xác định người dùng khác (sender hoặc receiver)
                final String otherUser = message['sender'] == widget.userId ? message['receiver'] : message['sender'];
                
                // Nếu chưa có tin nhắn cho người dùng này hoặc tin nhắn này mới hơn
                if (!latestMessagesByUser.containsKey(otherUser) || 
                    message['sentAt'].compareTo(latestMessagesByUser[otherUser]!['sentAt']) > 0) {
                  latestMessagesByUser[otherUser] = message;
                }
              }
              
              setState(() {
                _conversations.clear();
                _conversations.addAll(
                  latestMessagesByUser.entries.map((entry) {
                    final otherUser = entry.key;
                    final message = entry.value;
                    
                    return {
                      'id': otherUser,
                      'name': otherUser,  // Tên hiển thị là username, có thể cải thiện sau
                      'message': message['content'] ?? 'Chưa có tin nhắn',
                      'avatar': 'assets/images/avatar_default.png',
                      'timestamp': message['sentAt'] ?? DateTime.now().toIso8601String(),
                    };
                  }).toList(),
                );
                _isLoading = false;
              });
            } else {
              // Xử lý với định dạng API khác (nếu có)
              setState(() {
                _conversations.clear();
                _conversations.addAll(data.map((conv) => {
                  'id': conv['id'].toString(),
                  'name': conv['name'] ?? 'Người dùng',
                  'message': conv['lastMessage'] ?? 'Chưa có tin nhắn',
                  'avatar': 'assets/images/avatar_default.png',
                  'timestamp': conv['updatedAt'] ?? DateTime.now().toIso8601String(),
                }).toList());
                _isLoading = false;
              });
            }
            
            success = true;
            break;
          }
        } catch (e) {
          print('Lỗi khi lấy danh sách hội thoại từ $endpoint: $e');
        }
      }
      
      if (!success) {
        // Nếu không thể lấy dữ liệu từ API
        setState(() {
          _conversations.clear();
          _isLoading = false;
          _errorMessage = 'Không thể kết nối đến máy chủ';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi khi lấy danh sách hội thoại: $e';
      });
    }
  }
  

  
  // Tìm kiếm người dùng để tạo cuộc trò chuyện mới
  Future<List<Map<String, dynamic>>> _searchUsers(String query) async {
    if (_authToken == null) {
      return [];
    }
    
    try {
      final endpointsToTry = [
        'http://localhost:8080/api/users?search=$query',
        'http://10.0.2.2:8080/api/users?search=$query',
      ];
      
      for (String endpoint in endpointsToTry) {
        try {
          print('Tìm kiếm người dùng tại $endpoint...');
          
          final response = await http.get(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $_authToken',
            },
          ).timeout(const Duration(seconds: 10));
          
          if (response.statusCode == 200) {
            final List<dynamic> users = jsonDecode(response.body);
            
            // Lọc ra những người dùng không phải người dùng hiện tại
            return users
                .where((user) => user['username'].toString() != widget.userId)
                .map((user) => {
                  'id': user['username'].toString(),  // Sử dụng username làm id
                  'name': user['fullName'] ?? user['username'] ?? 'Người dùng',
                  'username': user['username'] ?? '',
                  'role': user['role'] ?? 'USER',
                }).toList();
          } else {
            print('Tìm kiếm thất bại: ${response.statusCode} - ${response.body}');
          }
        } catch (e) {
          print('Lỗi khi tìm kiếm người dùng tại $endpoint: $e');
        }
      }
      
      // Nếu không thể tìm kiếm qua API, trả về danh sách mẫu
      if (query.toLowerCase().contains('admin')) {
        return [
          {'id': 'admin', 'name': 'Administrator', 'username': 'admin', 'role': 'ADMIN'},
        ];
      } else {
        return [
          {'id': 'user2', 'name': 'Nguyễn Văn A', 'username': 'user2', 'role': 'USER'},
          {'id': 'user3', 'name': 'Trần Thị B', 'username': 'user3', 'role': 'USER'},
        ];
      }
    } catch (e) {
      print('Lỗi tìm kiếm người dùng: $e');
      return [];
    }
  }
  


  // Hiển thị dialog tạo cuộc trò chuyện mới
  void _showCreateChatDialog() {
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> searchResults = [];
    bool isSearching = false;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tạo cuộc trò chuyện mới'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Tìm người dùng',
                        hintText: 'Nhập tên hoặc username',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (query) async {
                        if (query.trim().length >= 2) {
                          setState(() {
                            isSearching = true;
                          });
                          
                          final results = await _searchUsers(query);
                          
                          setState(() {
                            searchResults = results;
                            isSearching = false;
                          });
                        } else if (query.isEmpty) {
                          setState(() {
                            searchResults = [];
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: isSearching
                          ? const Center(child: CircularProgressIndicator())
                          : searchResults.isEmpty
                              ? const Center(
                                  child: Text('Nhập tên để tìm kiếm người dùng'),
                                )
                              : ListView.builder(
                                  itemCount: searchResults.length,
                                  itemBuilder: (context, index) {
                                    final user = searchResults[index];
                                    final bool isAdmin = (user['role'] ?? '').toString().toUpperCase() == 'ADMIN';
                                    
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: isAdmin ? Colors.red : Colors.blue,
                                        child: Text(
                                          user['name'].toString().substring(0, 1).toUpperCase(),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      title: Text(user['name']),
                                      subtitle: Text('@${user['username']}${isAdmin ? ' (Admin)' : ''}'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _createConversation(user['id']);
                                      },
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      searchController.dispose();
    });
  }

  // Tạo cuộc trò chuyện mới với người dùng đã chọn
  Future<void> _createConversation(String otherUserId) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Gửi một tin nhắn ban đầu để tạo cuộc trò chuyện
      final endpointsToTry = [
        'http://localhost:8080/api/chat/send',
        'http://10.0.2.2:8080/api/chat/send',
      ];
      
      for (String endpoint in endpointsToTry) {
        try {
          print('Tạo cuộc trò chuyện tại $endpoint...');
          
          final response = await http.post(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $_authToken',
            },
            body: jsonEncode({
              "sender": widget.userId,
              "receiver": otherUserId,
              "content": "Xin chào!",
              "sentAt": DateTime.now().toIso8601String(),
            }),
          ).timeout(const Duration(seconds: 10));
          
          if (response.statusCode == 200 || response.statusCode == 201) {
            final messageData = jsonDecode(response.body);
            print('Gửi tin nhắn tạo cuộc trò chuyện thành công: ${messageData['id']}');
            
            // Làm mới danh sách cuộc trò chuyện
            await _fetchConversations();
            
            // Mở cuộc trò chuyện mới
            if (mounted) {
              // Chuyển đến màn hình chat
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatDetailScreen(
                    userName: _findUsername(otherUserId),
                    conversationId: otherUserId,
                    userId: widget.userId,
                    authToken: _authToken,
                  ),
                ),
              );
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã tạo cuộc trò chuyện mới'))
              );
            }
            return;
          } else {
            print('Tạo cuộc trò chuyện thất bại: ${response.statusCode} - ${response.body}');
          }
        } catch (e) {
          print('Lỗi khi tạo cuộc trò chuyện tại $endpoint: $e');
        }
      }
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tạo cuộc trò chuyện. Vui lòng thử lại sau.'),
            backgroundColor: Colors.red,
          )
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          )
        );
      }
    }
  }

  // Tìm tên hiển thị cho một userId
  String _findUsername(String userId) {
    // Tìm trong danh sách cuộc trò chuyện hiện tại
    for (final conversation in _conversations) {
      if (conversation['id'] == userId) {
        return conversation['name'] ?? userId;
      }
    }
    return userId; // Fallback to userId if name not found
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin nhắn'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _fetchConversations,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = _conversations[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(conversation['avatar']!),
                      ),
                      title: Text(conversation['name']!),
                      subtitle: Text(conversation['message']!),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatDetailScreen(
                              userName: conversation['name']!,
                              conversationId: conversation['id']!,
                              userId: widget.userId,
                              authToken: _authToken,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.chat, color: Colors.white),
        onPressed: () {
          _showCreateChatDialog();
        },
      ),
    );
  }
}

class ChatDetailScreen extends StatefulWidget {
  final String userName;
  final String conversationId;
  final String userId;
  final String? authToken;

  const ChatDetailScreen({
    super.key, 
    required this.userName, 
    required this.conversationId,
    required this.userId,
    this.authToken,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isSending = false;
  String _errorMessage = '';
  StreamSubscription? _chatSubscription;
  
  @override
  void initState() {
    super.initState();
    _initialize();
  }
  
  Future<void> _initialize() async {
    await _loadMessages();
    _setupChatService();
  }
  
  Future<void> _loadMessages() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      // Trong trường hợp thực tế, sẽ cần lấy username hoặc ID từ thông tin hội thoại
      // Giả định conversationId chứa thông tin người dùng khác, ví dụ "user2"
      final otherUser = widget.conversationId;
      
      final endpointsToTry = [
        'http://localhost:8080/api/chat/history?user1=${widget.userId}&user2=$otherUser',
        'http://10.0.2.2:8080/api/chat/history?user1=${widget.userId}&user2=$otherUser',
      ];
      
      bool success = false;
      
      for (String endpoint in endpointsToTry) {
        try {
          print('Đang lấy tin nhắn từ $endpoint...');
          
          final response = await http.get(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer ${widget.authToken}',
            },
          ).timeout(const Duration(seconds: 10));
          
          if (response.statusCode == 200) {
            final List<dynamic> data = jsonDecode(response.body);
            
            setState(() {
              _messages.clear();
              _messages.addAll(data.map((msg) => {
                'id': msg['id'].toString(),
                'senderId': msg['sender'],
                'text': msg['content'] ?? '',
                'timestamp': msg['sentAt'] ?? DateTime.now().toIso8601String(),
                'sender': msg['sender'] == widget.userId ? 'me' : 'other',
              }));
              _isLoading = false;
            });
            
            // Cuộn xuống tin nhắn cuối cùng
            _scrollToBottom();
            
            success = true;
            break;
          }
        } catch (e) {
          print('Lỗi khi lấy tin nhắn từ $endpoint: $e');
        }
      }
      
      // Nếu không thể lấy tin nhắn từ API, hiển thị tin nhắn mặc định
      if (!success) {
        setState(() {
          _messages.clear();
          _messages.addAll([
            {'sender': 'other', 'text': 'Tin nhắn demo: Bạn gửi file chấm công chưa?', 'timestamp': DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String()},
            {'sender': 'me', 'text': 'Tin nhắn demo: Mình gửi rồi nhé!', 'timestamp': DateTime.now().subtract(const Duration(minutes: 8)).toIso8601String()},
            {'sender': 'other', 'text': 'Tin nhắn demo: Ok, cảm ơn bạn!', 'timestamp': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String()},
          ]);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi khi tải tin nhắn: $e';
      });
    }
  }
  
  void _setupChatService() {
    // TODO: Kết nối đến ChatService và lắng nghe tin nhắn mới
    // Phần này sẽ được triển khai khi WebSocket đã sẵn sàng
  }
  
  void _addNewMessage(Map<String, dynamic> message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    
    _messageController.clear();
    
    // Add message to UI immediately (optimistic update)
    _addNewMessage({
      'id': 'temp-${DateTime.now().millisecondsSinceEpoch}',
      'senderId': widget.userId,
      'sender': 'me',
      'text': message,
      'timestamp': DateTime.now().toIso8601String(),
      'pending': true,
    });
    
    setState(() {
      _isSending = true;
    });
    
    try {
      // Trong trường hợp thực tế, sẽ cần lấy username hoặc ID từ thông tin hội thoại
      final otherUser = widget.conversationId;
      
      final endpointsToTry = [
        'http://localhost:8080/api/chat/send',
        'http://10.0.2.2:8080/api/chat/send',
      ];
      
      bool success = false;
      
      for (String endpoint in endpointsToTry) {
        try {
          final response = await http.post(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer ${widget.authToken}',
            },
            body: jsonEncode({
              'sender': widget.userId,
              'receiver': otherUser,
              'content': message,
              'sentAt': DateTime.now().toIso8601String(),
            }),
          ).timeout(const Duration(seconds: 10));
          
          if (response.statusCode == 200 || response.statusCode == 201) {
            success = true;
            break;
          }
        } catch (e) {
          print('Lỗi khi gửi tin nhắn tới $endpoint: $e');
        }
      }
      
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể gửi tin nhắn. Vui lòng thử lại sau.'),
            backgroundColor: Colors.red,
          )
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        )
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatSubscription?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 60),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadMessages,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['sender'] == 'me';
                      final isPending = msg['pending'] == true;
                      
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe 
                              ? isPending 
                                ? Colors.blue.withOpacity(0.5) 
                                : Colors.blue 
                              : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg['text']!,
                                style: TextStyle(
                                  fontSize: 14, 
                                  color: isMe ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimestamp(msg['timestamp']),
                                style: TextStyle(
                                  fontSize: 10, 
                                  color: isMe ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: _isSending 
                      ? const SizedBox(
                          width: 16, 
                          height: 16, 
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                    onPressed: _isSending ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  
  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        // Today: just show time
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (date.year == now.year) {
        // This year: show day/month
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else {
        // Different year: show day/month/year
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }
}
