import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'employee_list_screen.dart';
import '../services/user_api.dart';

class AssignTaskScreen extends StatefulWidget {
  final List<dynamic> allUsers;
  const AssignTaskScreen({Key? key, required this.allUsers}) : super(key: key);

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernamesController = TextEditingController();
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _dueDate;
  bool _loading = false;
  String? _result;

  List<String> get _usernamesList => widget.allUsers.map((u) => u['username']?.toString() ?? '').where((u) => u.isNotEmpty).toList();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _dueDate == null) return;
    setState(() { _loading = true; _result = null; });
    final body = {
      "usernames": _usernamesController.text.split(',').map((e) => e.trim()).toList(),
      "taskName": _taskNameController.text,
      "description": _descriptionController.text,
      "dueDate": _dueDate!.toIso8601String().substring(0, 10),
    };
    try {
      final res = await http.post(
        Uri.parse('http://10.0.2.2:8080/tasks'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      setState(() {
        _result = res.statusCode == 200 || res.statusCode == 201
            ? 'Giao nhiệm vụ thành công!'
            : 'Lỗi: ${res.statusCode}\n${res.body}';
      });
    } catch (e) {
      setState(() { _result = 'Lỗi kết nối: $e'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao nhiệm vụ'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Text('Chọn người nhận', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') {
                          return const Iterable<String>.empty();
                        }
                        return _usernamesList.where((String option) {
                          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                        _usernamesController.text = controller.text;
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          onEditingComplete: onEditingComplete,
                          decoration: InputDecoration(
                            labelText: 'Tên đăng nhập người nhận',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Nhập username' : null,
                        );
                      },
                      onSelected: (String selection) {
                        _usernamesController.text = selection;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _taskNameController,
                      decoration: InputDecoration(
                        labelText: 'Tên nhiệm vụ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.assignment),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Nhập tên nhiệm vụ' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Mô tả nhiệm vụ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      tileColor: Colors.blue.shade50,
                      title: Text(_dueDate == null ? 'Chọn hạn hoàn thành' : 'Hạn: ${_dueDate!.toLocal().toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _dueDate = picked);
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send),
                        label: const Text('Giao nhiệm vụ', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _loading ? null : () async {
                          await _submit();
                          if (_result != null && _result!.contains('thành công')) {
                            if (mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Giao nhiệm vụ thành công!')));
                            }
                          }
                        },
                      ),
                    ),
                    if (_result != null) ...[
                      const SizedBox(height: 16),
                      Text(_result!, style: TextStyle(color: _result!.contains('thành công') ? Colors.green : Colors.red)),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
