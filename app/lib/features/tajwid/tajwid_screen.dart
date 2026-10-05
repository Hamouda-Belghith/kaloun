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
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, i) {
                  final t = tajwid[i];
                  return ListTile(
                    leading: Icon(
                      Icons.account_tree_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(t.titre, style: Theme.of(context).textTheme.titleMedium),
                    trailing: t.fichiers.length > 1
                        ? Text(
                            '${t.fichiers.length} صفحات',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
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
