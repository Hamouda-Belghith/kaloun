import 'package:flutter/material.dart';

class GotoPageScreen extends StatefulWidget {
  const GotoPageScreen({super.key, required this.totalPages});

  final int totalPages;

  @override
  State<GotoPageScreen> createState() => _GotoPageScreenState();
}

class _GotoPageScreenState extends State<GotoPageScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_controller.text);
    if (value == null || value < 1 || value > widget.totalPages) {
      setState(() => _error = 'أدخل رقم صفحة بين 1 و ${widget.totalPages}');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الانتقال إلى صفحة')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'رقم الصفحة (1 - ${widget.totalPages})',
                  errorText: _error,
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _submit,
                child: const Text('انتقال'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
