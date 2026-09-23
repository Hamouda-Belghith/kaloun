import 'sourate.dart';
import 'juz.dart';

class NavigationData {
  final int totalPages;
  final List<Sourate> sourates;
  final List<Juz> juz;
  final List<Hizb> hizb;

  /// Première et dernière page (fichier) du texte coranique. Le numéro
  /// imprimé en bas de chaque page du Mosshaf est décalé de -1 par rapport
  /// à la position dans le fichier (page-fichier 3 -> "2" imprimé, jusqu'à
  /// page-fichier 605 -> "604" imprimé). Au-delà, une numérotation séparée
  /// ("١ م", "٢ م"...) commence pour les pages de fin (introduction/tajwid).
  final int premierePage;
  final int dernierePage;

  const NavigationData({
    required this.totalPages,
    required this.sourates,
    required this.juz,
    required this.hizb,
    required this.premierePage,
    required this.dernierePage,
  });

  factory NavigationData.fromJson(Map<String, dynamic> json) {
    final contenu = json['contenuCoranique'] as Map<String, dynamic>;
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
      premierePage: contenu['premierePage'] as int,
      dernierePage: contenu['dernierePage'] as int,
    );
  }

  /// Dernier numéro de page **imprimé** (celui visible en bas du Mosshaf).
  int get dernierePageImprimee => dernierePage - 1;

  /// Convertit un numéro de page imprimé (1 à [dernierePageImprimee]) en
  /// position dans le fichier (utilisée par le lecteur/`PageView`).
  int pageFichierDepuisPageImprimee(int pageImprimee) => pageImprimee + 1;

  /// Page (fichier) où commence la section "التعريف بالمصحف" (introduction,
  /// règles de tajwid...), juste après la dernière page coranique.
  int get pageDebutIntroduction => dernierePage + 1;

  /// Convertit une position fichier en numéro **imprimé** (celui visible en
  /// bas du Mosshaf), uniquement valable pour les pages coraniques.
  int pageImprimeeDepuisPageFichier(int pageFichier) => pageFichier - 1;

  /// Libellé humain d'une page (fichier) : numéro imprimé + nom de sourate
  /// pour le texte coranique, intitulé de la section pour les pages de fin.
  String libellePage(int pageFichier) {
    if (pageFichier >= pageDebutIntroduction) {
      return 'التعريف بالمصحف';
    }
    if (pageFichier < premierePage) {
      return 'الغلاف';
    }
    final sourate = sourateForPage(pageFichier);
    final numero = pageImprimeeDepuisPageFichier(pageFichier);
    return 'صفحة $numero - ${sourate.nomAr}';
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
