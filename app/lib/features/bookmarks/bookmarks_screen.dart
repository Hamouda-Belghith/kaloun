import 'package:flutter/material.dart';
import '../../core/models/bookmark.dart';
import '../../core/services/bookmark_service.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key, required this.currentPage});

  final int currentPage;

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Bookmark> _bookmarks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bookmarks = await BookmarkService.instance.getBookmarks();
    setState(() {
      _bookmarks = bookmarks;
      _loading = false;
    });
  }

  Future<void> _addCurrentPage() async {
    await BookmarkService.instance.addBookmark(
      Bookmark(page: widget.currentPage, createdAt: DateTime.now()),
    );
    await _load();
  }

  Future<void> _remove(int page) async {
    await BookmarkService.instance.removeBookmark(page);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإشارات المرجعية'),
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmark_add),
              tooltip: 'إضافة الصفحة الحالية',
              onPressed: _addCurrentPage,
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _bookmarks.isEmpty
                ? const Center(child: Text('لا توجد إشارات مرجعية بعد'))
                : ListView.separated(
                    itemCount: _bookmarks.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final b = _bookmarks[i];
                      return ListTile(
                        leading: const Icon(Icons.bookmark),
                        title: Text('صفحة ${b.page}'),
                        subtitle: Text(
                          '${b.createdAt.year}-${b.createdAt.month.toString().padLeft(2, '0')}-${b.createdAt.day.toString().padLeft(2, '0')}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _remove(b.page),
                        ),
                        onTap: () => Navigator.of(context).pop(b.page),
                      );
                    },
                  ),
      ),
    );
  }
}
