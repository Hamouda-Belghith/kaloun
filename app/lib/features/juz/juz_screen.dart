import 'package:flutter/material.dart';
import '../../core/models/juz.dart';
import '../../shared/widgets/roundel.dart';

class JuzScreen extends StatelessWidget {
  const JuzScreen({super.key, required this.juz});

  final List<Juz> juz;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الأجزاء')),
        body: ListView.separated(
          itemCount: juz.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
          itemBuilder: (context, i) {
            final j = juz[i];
            return ListTile(
              leading: Roundel(text: '${j.numero}'),
              title: Text(
                'الجزء ${j.nom}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              trailing: Text(
                'ص ${j.pageDebut}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => Navigator.of(context).pop(j.pageDebut),
            );
          },
        ),
      ),
    );
  }
}
