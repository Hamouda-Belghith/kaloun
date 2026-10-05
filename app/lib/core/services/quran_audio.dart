/// Récitation audio : Mahmoud Khalil Al-Hussary, **rawiya Qaloun 3an Nafi3**
/// (محمود خليل الحصري، رواية قالون عن نافع) — streaming depuis l'API
/// publique mp3quran.net (https://www.mp3quran.net/eng/api), conçue pour
/// être consommée par des apps tierces. Fichiers servis tels quels (pas
/// de copie embarquée dans l'app, pour ne pas bundler ~1,5 Go et pour
/// rester clairement dépendant du réseau pour cette seule fonctionnalité).
class QuranAudio {
  QuranAudio._();

  static const String reciterNomAr = 'محمود خليل الحصري';
  static const String riwayaNomAr = 'رواية قالون عن نافع';

  static const String _baseUrl =
      'https://cdn.mp3quran.net/audio/mahmoud-husary/r5/';

  /// URL de streaming de la récitation d'une sourate (1 à 114).
  static String urlForSourate(int numero) =>
      '$_baseUrl${numero.toString().padLeft(3, '0')}.mp3';
}
