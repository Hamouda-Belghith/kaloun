import 'package:flutter/material.dart';
import '../../core/models/tajwid_resource.dart';

class TajwidViewerScreen extends StatelessWidget {
  const TajwidViewerScreen({super.key, required this.resource});

  final TajwidResource resource;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(resource.titre)),
        body: InteractiveViewer(
          maxScale: 4,
          child: Center(
            child: Image.asset(resource.fichier, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
