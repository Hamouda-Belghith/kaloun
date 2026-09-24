import 'package:flutter/material.dart';
import '../../core/models/tajwid_resource.dart';

class TajwidViewerScreen extends StatefulWidget {
  const TajwidViewerScreen({super.key, required this.resource});

  final TajwidResource resource;

  @override
  State<TajwidViewerScreen> createState() => _TajwidViewerScreenState();
}

class _TajwidViewerScreenState extends State<TajwidViewerScreen> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fichiers = widget.resource.fichiers;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.resource.titre),
          bottom: fichiers.length > 1
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(24),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${_page + 1} / ${fichiers.length}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                )
              : null,
        ),
        body: PageView.builder(
          controller: _controller,
          itemCount: fichiers.length,
          onPageChanged: (i) => setState(() => _page = i),
          itemBuilder: (context, i) {
            return InteractiveViewer(
              maxScale: 4,
              child: Center(
                child: Image.asset(fichiers[i], fit: BoxFit.contain),
              ),
            );
          },
        ),
      ),
    );
  }
}
