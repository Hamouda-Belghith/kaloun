import 'package:flutter/material.dart';
import '../../core/models/tajwid_resource.dart';
import 'tajwid_viewer_screen.dart';

class TajwidScreen extends StatelessWidget {
  const TajwidScreen({super.key, required this.tajwid});

  final List<TajwidResource> tajwid;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('التجويد')),
        body: tajwid.isEmpty
            ? const Center(child: Text('لا توجد ملخصات بعد'))
            : ListView.separated(
                itemCount: tajwid.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final t = tajwid[i];
                  return ListTile(
                    leading: const Icon(Icons.account_tree_outlined),
                    title: Text(t.titre, style: const TextStyle(fontSize: 18)),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TajwidViewerScreen(resource: t),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
