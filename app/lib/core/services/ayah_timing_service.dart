import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ayah_timing.dart';

/// Minutage par verset, depuis l'API mp3quran.net (`ayat_timing`), pour
/// la rawiya Qaloun d'Al-Hussary spécifiquement (`read=270`, confirmé par
/// comparaison avec d'autres `read` : les horodatages diffèrent réellement
/// selon le récitateur/la rawiya demandés, ce n'est pas une réponse
/// générique). Permet de démarrer la lecture à un verset précis.
class AyahTimingService {
  AyahTimingService._();
  static final AyahTimingService instance = AyahTimingService._();

  /// Identifiant "read" de mp3quran.net pour Al-Hussary, rawiya Qaloun.
  static const int _readId = 270;

  final Map<int, List<AyahTiming>> _cache = {};

  Future<List<AyahTiming>> timingsForSourate(int numero) async {
    final cached = _cache[numero];
    if (cached != null) return cached;

    final uri = Uri.parse(
      'https://www.mp3quran.net/api/v3/ayat_timing?surah=$numero&read=$_readId',
    );
    final response = await http.get(uri);
    final list = (jsonDecode(response.body) as List)
        .map((e) => AyahTiming.fromJson(e as Map<String, dynamic>))
        .toList();
    _cache[numero] = list;
    return list;
  }

  /// Position de départ (dans le fichier audio de la sourate) pour un
  /// verset donné. Si le verset exact n'est pas dans les données (rare,
  /// ex. tout dernier verset d'une sourate parfois absent), on prend le
  /// plus proche disponible avant lui plutôt que d'échouer.
  Future<Duration?> startTimeForAyah(int sourateNumero, int ayah) async {
    final timings = await timingsForSourate(sourateNumero);
    if (timings.isEmpty) return null;
    for (final t in timings) {
      if (t.ayah == ayah) return t.startTime;
    }
    final before = timings.where((t) => t.ayah <= ayah).toList();
    if (before.isNotEmpty) return before.last.startTime;
    return timings.first.startTime;
  }
}
