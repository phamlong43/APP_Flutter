import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'PostEditScreen.dart';

class InternalCommunicationScreen extends StatefulWidget {
  final bool isAdmin;
  const InternalCommunicationScreen({super.key, required this.isAdmin});

  @override
  State<InternalCommunicationScreen> createState() => _InternalCommunicationScreenState();
}

class _InternalCommunicationScreenState extends State<InternalCommunicationScreen> {
  // Đã nhận isAdmin từ widget.isAdmin
  Future<void> likePost(int postId) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/posts/$postId/like');
    try {
      final res = await http.post(url);
      if (res.statusCode == 200) {
        await fetchPosts();
      }
    } catch (e) {}
  }

  Future<void> sharePost(int postId) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/posts/$postId/share');
    try {
      final res = await http.post(url);
      if (res.statusCode == 200) {
        await fetchPosts();
      }
    } catch (e) {}
  }
  List<dynamic> posts = [];
  bool isLoading = true;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    setState(() { isLoading = true; });
    try {
      final res = await http.get(Uri.parse('http://10.0.2.2:8080/api/posts'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) {
          posts = data;
        } else {
          posts = [];
        }
      } else {
        posts = [];
      }
    } catch (e) {
      posts = [];
    }
    setState(() { isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    // Lọc bài viết theo searchText
    List<dynamic> filteredPosts = searchText.isEmpty
        ? posts
        : posts.where((post) {
            final title = (post['title'] ?? '').toString().toLowerCase();
            final content = (post['content'] ?? '').toString().toLowerCase();
            final author = (post['author'] ?? '').toString().toLowerCase();
            final query = searchText.toLowerCase();
            return title.contains(query) || content.contains(query) || author.contains(query);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Truyền Thông Nội Bộ'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchText = value;
                      });
                    },
                  ),
                ),
                if (widget.isAdmin)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm'),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PostEditScreen(isEdit: false),
                          ),
                        );
                        if (result == true) fetchPosts();
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredPosts.isEmpty
                    ? const Center(child: Text('Không có bài viết nào.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: filteredPosts.length,
                        itemBuilder: (context, i) {
                          final post = filteredPosts[i];
                          // Xử lý createdAt null hoặc định dạng thời gian
                          String time = '';
                          if (post['createdAt'] != null) {
                            time = post['createdAt'].toString();
                          } else {
                            time = 'Chưa xác định';
                          }
                          // Xử lý visibility và shared nếu muốn hiển thị
                          String visibility = post['visibility'] ?? '';
                          int shared = post['shared'] ?? 0;
                          return _buildPostCard(
                            userName: post['author'] ?? '',
                            time: time,
                            contentTitle: post['title'] ?? '',
                            contentBody: post['content'] ?? '',
                            likes: post['likes'] ?? 0,
                            comments: post['commentsCount'] ?? 0,
                            userAvatar: 'assets/user1.png',
                            visibility: visibility,
                            shared: shared,
                            postId: post['postId'],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard({
    required String userName,
    required String time,
    required String contentTitle,
    required String contentBody,
    required int likes,
    required int comments,
    required String userAvatar,
    String? visibility,
    int? shared,
    int? postId,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 20, backgroundImage: AssetImage(userAvatar)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (visibility != null && visibility.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text('[$visibility]', style: const TextStyle(fontSize: 12, color: Colors.blue)),
                            ),
                        ],
                      ),
                      Text(time, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                if (widget.isAdmin && postId != null) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostEditScreen(
                            isEdit: true,
                            post: {
                              'postId': postId,
                              'author': userName,
                              'title': contentTitle,
                              'content': contentBody,
                              'visibility': visibility,
                            },
                          ),
                        ),
                      );
                      if (result == true) fetchPosts();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Xác nhận xóa
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Xác nhận'),
                          content: const Text('Bạn có chắc muốn xóa bài viết này?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Không')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa')),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await deletePost(postId);
                      }
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(contentTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(contentBody),
            const SizedBox(height: 10),
            Row(
              children: [
                GestureDetector(
                  onTap: postId != null ? () => likePost(postId) : null,
                  child: Row(
                    children: [
                      Icon(Icons.thumb_up_alt_outlined, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('$likes'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.comment_outlined, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('$comments'),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: postId != null ? () => sharePost(postId) : null,
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${shared ?? 0}'),
                    ],
                  ),
                ),
                const Spacer(),
                CircleAvatar(radius: 10, backgroundImage: AssetImage(userAvatar)),
              ],
            )
          ],
        ),
      ),
    );
  }
  Future<void> deletePost(int postId) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/posts/$postId');
    try {
      final res = await http.delete(url);
      if (res.statusCode == 200) {
        await fetchPosts();
      }
    } catch (e) {}
  }
}
