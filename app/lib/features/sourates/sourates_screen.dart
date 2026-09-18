import 'package:flutter/material.dart';
import '../../core/models/sourate.dart';

class SouratesScreen extends StatelessWidget {
  const SouratesScreen({super.key, required this.sourates});

  final List<Sourate> sourates;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('السور')),
        body: ListView.separated(
          itemCount: sourates.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final s = sourates[i];
            return ListTile(
              leading: CircleAvatar(child: Text('${s.numero}')),
              title: Text(s.nomAr, style: const TextStyle(fontSize: 18)),
              subtitle: Text(
                '${s.nomFr} · ${s.nombreAyat} versets · '
                '${s.estMecquoise ? "مكية" : "مدنية"}',
              ),
              trailing: Text('ص ${s.pageDebut}'),
              onTap: () => Navigator.of(context).pop(s.pageDebut),
            );
          },
        ),
      ),
    );
  }
}
