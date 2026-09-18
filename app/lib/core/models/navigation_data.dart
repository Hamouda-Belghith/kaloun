import 'sourate.dart';
import 'juz.dart';

class NavigationData {
  final int totalPages;
  final List<Sourate> sourates;
  final List<Juz> juz;
  final List<Hizb> hizb;

  const NavigationData({
    required this.totalPages,
    required this.sourates,
    required this.juz,
    required this.hizb,
  });

  factory NavigationData.fromJson(Map<String, dynamic> json) {
    return NavigationData(
      totalPages: json['totalPages'] as int,
      sourates: (json['sourates'] as List)
          .map((e) => Sourate.fromJson(e as Map<String, dynamic>))
          .toList(),
      juz: (json['juz'] as List)
          .map((e) => Juz.fromJson(e as Map<String, dynamic>))
          .toList(),
      hizb: (json['hizb'] as List)
          .map((e) => Hizb.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Sourate active pour une page donnée (la dernière dont pageDebut <= page).
  Sourate sourateForPage(int page) {
    Sourate result = sourates.first;
    for (final s in sourates) {
      if (s.pageDebut <= page) {
        result = s;
      } else {
        break;
      }
    }
    return result;
  }

  Juz juzForPage(int page) {
    Juz result = juz.first;
    for (final j in juz) {
      if (j.pageDebut <= page) {
        result = j;
      } else {
        break;
      }
    }
    return result;
  }
}
