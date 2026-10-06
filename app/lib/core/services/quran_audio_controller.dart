import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'ayah_timing_service.dart';
import 'quran_audio.dart';

/// Comportement en fin de sourate.
enum QuranPlaybackMode {
  /// Revient au début et rejoue la même sourate (utile pour la mémorisation).
  repeatOne,

  /// Enchaîne sur la sourate suivante (récitation continue).
  continueNext,
}

/// Contrôleur audio unique pour toute l'app : l'état (sourate en cours,
/// mode de lecture) survit à la navigation entre écrans, pour que la
/// lecture lancée depuis la liste des sourates continue si on revient au
/// lecteur de pages, et inversement.
class QuranAudioController {
  QuranAudioController._() {
    player.playerStateStream.listen(_onPlayerStateChanged);
  }

  static final QuranAudioController instance = QuranAudioController._();

  final AudioPlayer player = AudioPlayer();
  final ValueNotifier<int?> currentSourateNumero = ValueNotifier(null);
  final ValueNotifier<QuranPlaybackMode> mode =
      ValueNotifier(QuranPlaybackMode.continueNext);
  final ValueNotifier<String?> error = ValueNotifier(null);

  Future<void> playSourate(int numero) async {
    error.value = null;
    if (currentSourateNumero.value == numero) {
      player.playing ? await player.pause() : await player.play();
      return;
    }
    currentSourateNumero.value = numero;
    try {
      await player.setUrl(QuranAudio.urlForSourate(numero));
      await player.play();
    } catch (_) {
      error.value = 'تعذّر تحميل التلاوة. تحقق من اتصالك بالإنترنت.';
      currentSourateNumero.value = null;
    }
  }

  /// Démarre une sourate à partir d'un verset précis plutôt que du début
  /// (ex. verset 150 d'Al-Baqara). Récupère le minutage par verset depuis
  /// [AyahTimingService], puis cherche dans le fichier audio.
  Future<void> playSourateFromAyah(int numero, int ayah) async {
    error.value = null;
    currentSourateNumero.value = numero;
    try {
      await player.setUrl(QuranAudio.urlForSourate(numero));
      final startTime =
          await AyahTimingService.instance.startTimeForAyah(numero, ayah);
      if (startTime != null) {
        await player.seek(startTime);
      }
      await player.play();
    } catch (_) {
      error.value = 'تعذّر تحميل التلاوة. تحقق من اتصالك بالإنترنت.';
      currentSourateNumero.value = null;
    }
  }

  Future<void> togglePlayPause() async {
    if (currentSourateNumero.value == null) return;
    player.playing ? await player.pause() : await player.play();
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

  void toggleMode() {
    mode.value = mode.value == QuranPlaybackMode.repeatOne
        ? QuranPlaybackMode.continueNext
        : QuranPlaybackMode.repeatOne;
  }

  Future<void> stop() async {
    await player.stop();
    currentSourateNumero.value = null;
  }

  void _onPlayerStateChanged(PlayerState state) {
    if (state.processingState != ProcessingState.completed) return;
    final current = currentSourateNumero.value;
    if (current == null) return;
    if (mode.value == QuranPlaybackMode.repeatOne) {
      player.seek(Duration.zero);
      player.play();
    } else if (current < 114) {
      playSourate(current + 1);
    } else {
      stop();
    }
  }
}
