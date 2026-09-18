import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark.dart';

/// Gère le signet "dernière page lue" et les signets manuels
/// en stockage local (shared_preferences).
class BookmarkService {
  BookmarkService._();
  static final BookmarkService instance = BookmarkService._();

  static const _lastPageKey = 'last_read_page';
  static const _bookmarksKey = 'bookmarks';

  Future<int?> getLastReadPage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastPageKey);
  }

  Future<void> setLastReadPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPageKey, page);
  }

  Future<List<Bookmark>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_bookmarksKey) ?? const [];
    return raw
        .map((s) => Bookmark.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.page.compareTo(b.page));
  }

  Future<void> addBookmark(Bookmark bookmark) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_bookmarksKey) ?? <String>[];
    current.add(jsonEncode(bookmark.toJson()));
    await prefs.setStringList(_bookmarksKey, current);
  }

  Future<void> removeBookmark(int page) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_bookmarksKey) ?? <String>[];
    current.removeWhere((s) {
      final decoded = jsonDecode(s) as Map<String, dynamic>;
      return decoded['page'] == page;
    });
    await prefs.setStringList(_bookmarksKey, current);
  }
}
