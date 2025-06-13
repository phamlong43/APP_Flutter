import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DigitalSignatureScreen extends StatefulWidget {
  final String username;
  const DigitalSignatureScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<DigitalSignatureScreen> createState() => _DigitalSignatureScreenState();
}

class _DigitalSignatureScreenState extends State<DigitalSignatureScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  Uint8List? _savedSignature;
  bool _saving = false;
  String? _signaturePath;

  @override
  void initState() {
    super.initState();
    _loadSignature();
  }

  Future<String> _getSignatureFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/signature_${widget.username}.png';
  }

  Future<void> _loadSignature() async {
    final path = await _getSignatureFilePath();
    final file = File(path);
    if (await file.exists()) {
      setState(() {
        _signaturePath = path;
        _savedSignature = file.readAsBytesSync();
      });
    }
  }

  Future<void> _saveSignature() async {
    if (_controller.isNotEmpty) {
      setState(() { _saving = true; });
      final signature = await _controller.toPngBytes();
      if (signature != null) {
        final path = await _getSignatureFilePath();
        final file = File(path);
        await file.writeAsBytes(signature);
        setState(() {
          _savedSignature = signature;
          _signaturePath = path;
          _saving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã lưu chữ ký vào $path')));
      } else {
        setState(() { _saving = false; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể lưu chữ ký.')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng ký trước khi lưu.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chữ ký điện tử'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Vui lòng ký vào khung bên dưới:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Signature(
                controller: _controller,
                height: 220,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text('Xóa'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    _controller.clear();
                  },
                ),
                const SizedBox(width: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: _saving ? const Text('Đang lưu...') : const Text('Lưu'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: _saving ? null : _saveSignature,
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_savedSignature != null) ...[
              const Text('Chữ ký đã lưu:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.memory(_savedSignature!, height: 120),
              ),
              if (_signaturePath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Đường dẫn: $_signaturePath', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
