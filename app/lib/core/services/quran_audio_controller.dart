import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ayah_timing.dart';
import 'ayah_timing_service.dart';
import 'quran_audio.dart';

/// Ce qui constitue une "unité" de répétition.
enum RepeatScope {
  /// Un seul verset (utile pour la mémorisation).
  ayah,

  /// La sourate entière (ou sa fin, à partir du verset de départ choisi).
  sourate,
}

/// Contrôleur audio unique pour toute l'app : l'état (sourate/verset en
/// cours, options de répétition) survit à la navigation entre écrans, et
/// le dernier verset écouté est mémorisé localement pour reprendre au
/// même endroit après avoir fermé puis rouvert l'app.
class QuranAudioController {
  QuranAudioController._() {
    player.playerStateStream.listen(_onPlayerStateChanged);
    player.positionStream.listen(_onPositionChanged);
    _restoreLastPosition();
  }

  static final QuranAudioController instance = QuranAudioController._();

  static const _prefsSourateKey = 'audio_last_sourate';
  static const _prefsAyahKey = 'audio_last_ayah';

  final AudioPlayer player = AudioPlayer();
  final ValueNotifier<int?> currentSourateNumero = ValueNotifier(null);
  final ValueNotifier<int?> currentAyah = ValueNotifier(null);
  final ValueNotifier<RepeatScope> repeatScope = ValueNotifier(RepeatScope.sourate);
  final ValueNotifier<int> repeatCount = ValueNotifier(1);
  final ValueNotifier<String?> error = ValueNotifier(null);

  /// `true` une fois qu'un fichier audio a réellement été chargé dans le
  /// lecteur. [currentSourateNumero]/[currentAyah] peuvent être renseignés
  /// (ex. position restaurée au démarrage) sans que ce soit encore le cas :
  /// il faut alors lancer une vraie lecture avant de pouvoir mettre en
  /// pause/reprendre.
  final ValueNotifier<bool> sourceReady = ValueNotifier(false);

  /// Visibilité du panneau de contrôle (barre de lecture). Peut être
  /// ouverte manuellement (flèche) ou temporairement (tap sur la page),
  /// et se referme toute seule après [_autoHideDelay] sans nouvelle
  /// sollicitation.
  final ValueNotifier<bool> panelExpanded = ValueNotifier(false);
  static const _autoHideDelay = Duration(seconds: 10);
  Timer? _hideTimer;

  void showPanelTemporarily() {
    panelExpanded.value = true;
    _hideTimer?.cancel();
    _hideTimer = Timer(_autoHideDelay, () => panelExpanded.value = false);
  }

  void togglePanel() {
    if (panelExpanded.value) {
      _hideTimer?.cancel();
      panelExpanded.value = false;
    } else {
      showPanelTemporarily();
    }
  }

  List<AyahTiming> _timings = [];
  Duration? _loopStart;
  Duration? _loopEnd; // null = jusqu'à la fin du fichier
  int _repeatsRemaining = 1;

  void setRepeatOptions({required RepeatScope scope, required int count}) {
    repeatScope.value = scope;
    repeatCount.value = count.clamp(1, 99);
  }

  Future<void> _restoreLastPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final numero = prefs.getInt(_prefsSourateKey);
      final ayah = prefs.getInt(_prefsAyahKey);
      if (numero == null) return;
      currentSourateNumero.value = numero;
      currentAyah.value = ayah ?? 1;
      // Minutage chargé à l'avance (léger, pas d'audio) pour que
      // précédent/suivant fonctionnent dès que la lecture démarre.
      _timings = await AyahTimingService.instance.timingsForSourate(numero);
    } catch (_) {
      // Pas grave : on perd juste la reprise, l'app reste utilisable.
    }
  }

  Future<void> _saveLastPosition(int numero, int ayah) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsSourateKey, numero);
      await prefs.setInt(_prefsAyahKey, ayah);
    } catch (_) {
      // Pas grave : juste la reprise qui ne sera pas mémorisée.
    }
  }

  /// Point d'entrée pour un simple bouton lecture : reprend si une lecture
  /// est déjà chargée pour cette sourate, relance depuis le dernier verset
  /// connu si la sourate était seulement restaurée (pas encore chargée),
  /// ou démarre une sourate différente depuis son premier verset.
  Future<void> playOrResume(int numero) async {
    if (currentSourateNumero.value == numero) {
      if (sourceReady.value) {
        await togglePlayPause();
      } else {
        await playSourateFromAyah(numero, currentAyah.value ?? 1);
      }
      return;
    }
    await playSourate(numero);
  }

  Future<void> playSourate(int numero, {int startAyah = 1}) async {
    error.value = null;
    sourceReady.value = false;
    currentSourateNumero.value = numero;
    currentAyah.value = null;
    _timings = [];
    try {
      _timings = await AyahTimingService.instance.timingsForSourate(numero);
    } catch (_) {
      // Pas grave : on perd juste le suivi du verset en cours et le
      // bouclage précis, la lecture de la sourate reste possible.
    }
    try {
      await player.setUrl(QuranAudio.urlForSourate(numero));
      _setupLoop(startAyah);
      if (_loopStart != null) await player.seek(_loopStart);
      sourceReady.value = true;
      await player.play();
      await _saveLastPosition(numero, startAyah);
    } catch (_) {
      error.value = 'تعذّر تحميل التلاوة. تحقق من اتصالك بالإنترنت.';
      currentSourateNumero.value = null;
      sourceReady.value = false;
    }
  }

  Future<void> playSourateFromAyah(int numero, int ayah) => playSourate(numero, startAyah: ayah);

  void _setupLoop(int startAyah) {
    _repeatsRemaining = repeatCount.value;
    final timing = _timingFor(startAyah);
    _loopStart = timing?.startTime;
    _loopEnd = repeatScope.value == RepeatScope.ayah ? timing?.endTime : null;
  }

  AyahTiming? _timingFor(int ayah) {
    if (_timings.isEmpty) return null;
    for (final t in _timings) {
      if (t.ayah == ayah) return t;
    }
    final before = _timings.where((t) => t.ayah <= ayah).toList();
    return before.isNotEmpty ? before.last : _timings.first;
  }

  Future<void> togglePlayPause() async {
    if (!sourceReady.value) return;
    player.playing ? await player.pause() : await player.play();
  }

  Future<void> previousAyah() async {
    if (!sourceReady.value) return;
    final ayah = currentAyah.value;
    final numero = currentSourateNumero.value;
    if (ayah == null || numero == null || ayah <= 1) return;
    _setupLoop(ayah - 1);
    await player.seek(_loopStart ?? Duration.zero);
  }

  Future<void> nextAyah() async {
    if (!sourceReady.value) return;
    final ayah = currentAyah.value;
    final numero = currentSourateNumero.value;
    if (ayah == null || numero == null) return;
    if (_timings.isNotEmpty && ayah >= _timings.last.ayah) return;
    _setupLoop(ayah + 1);
    await player.seek(_loopStart ?? Duration.zero);
  }

  Future<void> previous() async {
    final current = currentSourateNumero.value;
    if (current == null || current <= 1) return;
    await playSourate(current - 1);
  }

  Future<void> next() async {
    final current = currentSourateNumero.value;
    if (current == null || current >= 114) return;
    await playSourate(current + 1);
  }

  Future<void> stop() async {
    if (sourceReady.value) await player.stop();
    sourceReady.value = false;
    currentSourateNumero.value = null;
    currentAyah.value = null;
  }

  void _onPositionChanged(Duration position) {
    if (_timings.isNotEmpty) {
      AyahTiming? found;
      for (final t in _timings) {
        if (position >= t.startTime) {
          found = t;
        } else {
          break;
        }
      }
      if (found != null && found.ayah != currentAyah.value) {
        currentAyah.value = found.ayah;
        final numero = currentSourateNumero.value;
        if (numero != null) _saveLastPosition(numero, found.ayah);
      }
    }
    final loopEnd = _loopEnd;
    if (loopEnd != null && position >= loopEnd) {
      _advanceAfterLoopEnd();
    }
  }

  void _advanceAfterLoopEnd() {
    if (_repeatsRemaining > 1) {
      _repeatsRemaining--;
      player.seek(_loopStart ?? Duration.zero);
      return;
    }
    // Répétitions épuisées : avance au verset suivant (le fichier entier
    // continue naturellement si on ne boucle plus dessus).
    final numero = currentSourateNumero.value;
    final ayah = currentAyah.value;
    if (numero == null || ayah == null) return;
    if (_timings.isNotEmpty && ayah < _timings.last.ayah) {
      _setupLoop(ayah + 1);
    } else {
      _loopEnd = null; // dernier verset connu : laisse filer jusqu'à la fin
    }
  }

  void _onPlayerStateChanged(PlayerState state) {
    if (state.processingState != ProcessingState.completed) return;
    final current = currentSourateNumero.value;
    if (current == null) return;
    if (repeatScope.value == RepeatScope.sourate && _repeatsRemaining > 1) {
      _repeatsRemaining--;
      player.seek(_loopStart ?? Duration.zero);
      player.play();
      return;
    }
    if (current < 114) {
      playSourate(current + 1);
    } else {
      stop();
    }
  }
}
