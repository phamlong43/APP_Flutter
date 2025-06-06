import 'package:flutter/material.dart';

class AddWorkHoursScreen extends StatefulWidget {
  const AddWorkHoursScreen({super.key});

  @override
  State<AddWorkHoursScreen> createState() => _AddWorkHoursScreenState();
}

class _AddWorkHoursScreenState extends State<AddWorkHoursScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String reason = '';

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      // Ở đây bạn có thể xử lý logic lưu yêu cầu vào hệ thống
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yêu cầu bổ sung công đã được gửi')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bổ Sung Công'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              title: const Text('Ngày làm việc'),
              subtitle: Text(selectedDate != null
                  ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                  : 'Chọn ngày'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('Giờ bắt đầu'),
              subtitle: Text(startTime != null ? startTime!.format(context) : 'Chọn giờ'),
              trailing: const Icon(Icons.access_time),
              onTap: () => _pickTime(isStart: true),
            ),
            ListTile(
              title: const Text('Giờ kết thúc'),
              subtitle: Text(endTime != null ? endTime!.format(context) : 'Chọn giờ'),
              trailing: const Icon(Icons.access_time),
              onTap: () => _pickTime(isStart: false),
            ),
            const SizedBox(height: 10),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Lý do bổ sung',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập lý do' : null,
              onChanged: (value) => reason = value,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submitRequest,
              icon: const Icon(Icons.send),
              label: const Text('Gửi yêu cầu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            )
          ],
        ),
      ),
    );
  }
}
