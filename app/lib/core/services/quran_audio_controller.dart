import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
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
/// cours, options de répétition) survit à la navigation entre écrans.
class QuranAudioController {
  QuranAudioController._() {
    player.playerStateStream.listen(_onPlayerStateChanged);
    player.positionStream.listen(_onPositionChanged);
  }

  static final QuranAudioController instance = QuranAudioController._();

  final AudioPlayer player = AudioPlayer();
  final ValueNotifier<int?> currentSourateNumero = ValueNotifier(null);
  final ValueNotifier<int?> currentAyah = ValueNotifier(null);
  final ValueNotifier<RepeatScope> repeatScope = ValueNotifier(RepeatScope.sourate);
  final ValueNotifier<int> repeatCount = ValueNotifier(1);
  final ValueNotifier<String?> error = ValueNotifier(null);

  List<AyahTiming> _timings = [];
  Duration? _loopStart;
  Duration? _loopEnd; // null = jusqu'à la fin du fichier
  int _repeatsRemaining = 1;

  void setRepeatOptions({required RepeatScope scope, required int count}) {
    repeatScope.value = scope;
    repeatCount.value = count.clamp(1, 99);
  }

  Future<void> playSourate(int numero, {int startAyah = 1}) async {
    error.value = null;
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
      await player.play();
    } catch (_) {
      error.value = 'تعذّر تحميل التلاوة. تحقق من اتصالك بالإنترنت.';
      currentSourateNumero.value = null;
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
    if (currentSourateNumero.value == null) return;
    player.playing ? await player.pause() : await player.play();
  }

  Future<void> previousAyah() async {
    final ayah = currentAyah.value;
    final numero = currentSourateNumero.value;
    if (ayah == null || numero == null || ayah <= 1) return;
    _setupLoop(ayah - 1);
    await player.seek(_loopStart ?? Duration.zero);
  }

  Future<void> nextAyah() async {
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
    await player.stop();
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
