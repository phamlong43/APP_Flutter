import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PostEditScreen extends StatefulWidget {
  final Map<String, dynamic>? post;
  final bool isEdit;
  const PostEditScreen({super.key, this.post, this.isEdit = false});

  @override
  State<PostEditScreen> createState() => _PostEditScreenState();
}

class _PostEditScreenState extends State<PostEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController authorController;
  late TextEditingController titleController;
  late TextEditingController contentController;
  String visibility = 'PUBLIC';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    authorController = TextEditingController(text: widget.post?['author'] ?? '');
    titleController = TextEditingController(text: widget.post?['title'] ?? '');
    contentController = TextEditingController(text: widget.post?['content'] ?? '');
    visibility = widget.post?['visibility'] ?? 'PUBLIC';
  }

  @override
  void dispose() {
    authorController.dispose();
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { isLoading = true; });
    final data = {
      'author': authorController.text,
      'title': titleController.text,
      'content': contentController.text,
      'visibility': visibility,
    };
    try {
      http.Response res;
      if (widget.isEdit && widget.post?['postId'] != null) {
        res = await http.put(
          Uri.parse('http://10.0.2.2:8080/api/posts/${widget.post!['postId']}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );
      } else {
        res = await http.post(
          Uri.parse('http://10.0.2.2:8080/api/posts'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );
      }
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${res.statusCode} - ${res.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kết nối: $e')),
      );
    }
    setState(() { isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Chỉnh sửa bài viết' : 'Thêm bài viết'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: authorController,
                decoration: const InputDecoration(labelText: 'Tác giả'),
                validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
                validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Nội dung'),
                maxLines: 5,
                validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: visibility,
                items: const [
                  DropdownMenuItem(value: 'PUBLIC', child: Text('Công khai')),
                  DropdownMenuItem(value: 'PRIVATE', child: Text('Riêng tư')),
                ],
                onChanged: (v) => setState(() => visibility = v ?? 'PUBLIC'),
                decoration: const InputDecoration(labelText: 'Chế độ hiển thị'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : submit,
                child: isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(widget.isEdit ? 'Cập nhật' : 'Tạo mới'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
