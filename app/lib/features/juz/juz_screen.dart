import 'package:flutter/material.dart';
import '../../core/models/juz.dart';

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
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final j = juz[i];
            return ListTile(
              leading: CircleAvatar(child: Text('${j.numero}')),
              title: Text('الجزء ${j.numero}'),
              trailing: Text('ص ${j.pageDebut}'),
              onTap: () => Navigator.of(context).pop(j.pageDebut),
            );
          },
        ),
      ),
    );
  }
}
