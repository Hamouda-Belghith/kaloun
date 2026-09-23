import 'package:flutter/material.dart';
import '../../core/models/navigation_data.dart';

class GotoPageScreen extends StatefulWidget {
  const GotoPageScreen({super.key, required this.data});

  final NavigationData data;

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
    final maxPage = widget.data.dernierePageImprimee;
    final value = int.tryParse(_controller.text);
    if (value == null || value < 1 || value > maxPage) {
      setState(() => _error = 'أدخل رقم صفحة بين 1 و $maxPage');
      return;
    }
    Navigator.of(context).pop(widget.data.pageFichierDepuisPageImprimee(value));
  }

  @override
  Widget build(BuildContext context) {
    final maxPage = widget.data.dernierePageImprimee;
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
                  labelText: 'رقم الصفحة (1 - $maxPage)',
                  errorText: _error,
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _submit,
                child: const Text('انتقال'),
              ),
              const SizedBox(height: 24),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('التعريف بالمصحف'),
                subtitle: const Text('مقدمة الطبعة وقواعد التجويد'),
                onTap: () => Navigator.of(context)
                    .pop(widget.data.pageDebutIntroduction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
