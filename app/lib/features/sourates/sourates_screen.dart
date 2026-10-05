import 'package:flutter/material.dart';
import '../../core/models/sourate.dart';
import '../../shared/widgets/roundel.dart';

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
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
          itemBuilder: (context, i) {
            final s = sourates[i];
            return ListTile(
              leading: Roundel(text: '${s.numero}'),
              title: Text(s.nomAr, style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(
                '${s.nomFr} · ${s.nombreAyat} آية · '
                '${s.estMecquoise ? "مكية" : "مدنية"}',
              ),
              trailing: Text(
                'ص ${s.pageDebut}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => Navigator.of(context).pop(s.pageDebut),
            );
          },
        ),
      ),
    );
  }
}
