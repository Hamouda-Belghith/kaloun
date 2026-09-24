import 'package:flutter/material.dart';
import '../../core/models/navigation_data.dart';
import '../../core/services/bookmark_service.dart';
import '../../core/services/navigation_data_service.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../goto_page/goto_page_screen.dart';
import '../juz/juz_screen.dart';
import '../sourates/sourates_screen.dart';
import '../tajwid/tajwid_screen.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key, this.initialPage});

  /// Page à ouvrir au démarrage (1-indexée). Si null, reprend la dernière
  /// page lue, sinon page 1.
  final int? initialPage;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  NavigationData? _navigationData;
  late PageController _controller;
  int _currentPage = 1; // 1-indexée
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final data = await NavigationDataService.instance.load();
    final startPage = widget.initialPage ??
        await BookmarkService.instance.getLastReadPage() ??
        1;
    setState(() {
      _navigationData = data;
      _currentPage = startPage.clamp(1, data.totalPages);
      _controller = PageController(initialPage: _currentPage - 1);
      _ready = true;
    });
  }

  @override
  void dispose() {
    if (_ready) _controller.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    final total = _navigationData!.totalPages;
    final target = page.clamp(1, total);
    _controller.jumpToPage(target - 1);
  }

  Future<void> _onPageChanged(int index) async {
    final page = index + 1;
    setState(() => _currentPage = page);
    await BookmarkService.instance.setLastReadPage(page);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final data = _navigationData!;
    final sourate = data.sourateForPage(_currentPage);
    final juz = data.juzForPage(_currentPage);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${sourate.nomAr}  ·  الجزء ${juz.numero}'),
        ),
        body: PageView.builder(
          controller: _controller,
          // Pas de `reverse` : le Directionality RTL parent place déjà la page 1
          // à droite et fait avancer vers la gauche (`reverse: true` annulerait ça).
          itemCount: data.totalPages,
          onPageChanged: _onPageChanged,
          itemBuilder: (context, index) {
            final pageNumber = index + 1;
            return InteractiveViewer(
              maxScale: 4,
              child: Center(
                child: Image.asset(
                  'assets/pages/page_${pageNumber.toString().padLeft(4, '0')}.webp',
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavButton(
                icon: Icons.menu_book,
                label: 'سور',
                onPressed: () async {
                  final page = await Navigator.of(context).push<int>(
                    MaterialPageRoute(
                      builder: (_) => SouratesScreen(sourates: data.sourates),
                    ),
                  );
                  if (page != null) _goToPage(page);
                },
              ),
              _NavButton(
                icon: Icons.view_list,
                label: 'أجزاء',
                onPressed: () async {
                  final page = await Navigator.of(context).push<int>(
                    MaterialPageRoute(
                      builder: (_) => JuzScreen(juz: data.juz),
                    ),
                  );
                  if (page != null) _goToPage(page);
                },
              ),
              _NavButton(
                icon: Icons.pin,
                label: 'صفحة',
                onPressed: () async {
                  final page = await Navigator.of(context).push<int>(
                    MaterialPageRoute(
                      builder: (_) => GotoPageScreen(data: data),
                    ),
                  );
                  if (page != null) _goToPage(page);
                },
              ),
              _NavButton(
                icon: Icons.bookmark,
                label: 'إشارات',
                onPressed: () async {
                  final page = await Navigator.of(context).push<int>(
                    MaterialPageRoute(
                      builder: (_) => BookmarksScreen(
                        currentPage: _currentPage,
                        data: data,
                      ),
                    ),
                  );
                  if (page != null) _goToPage(page);
                },
              ),
              _NavButton(
                icon: Icons.account_tree_outlined,
                label: 'تجويد',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TajwidScreen(tajwid: data.tajwid),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
