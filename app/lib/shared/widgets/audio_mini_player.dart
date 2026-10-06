import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/models/sourate.dart';
import '../../core/services/quran_audio.dart';
import '../../core/services/quran_audio_controller.dart';

/// Mini-lecteur persistant : lecture/pause, précédent/suivant, bascule
/// du mode (répéter cette sourate / continuer), barre de progression,
/// arrêt. Visible depuis n'importe quel écran qui l'inclut, tant qu'une
/// sourate est chargée dans [QuranAudioController].
class AudioMiniPlayer extends StatelessWidget {
  const AudioMiniPlayer({super.key, required this.sourates});

  final List<Sourate> sourates;

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final controller = QuranAudioController.instance;
    final scheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<int?>(
      valueListenable: controller.currentSourateNumero,
      builder: (context, numero, __) {
        if (numero == null) return const SizedBox.shrink();
        final sourate = sourates.firstWhere((s) => s.numero == numero);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(top: BorderSide(color: scheme.tertiary, width: 1)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        tooltip: 'السورة السابقة',
                        onPressed: numero > 1 ? controller.previous : null,
                      ),
                      StreamBuilder<PlayerState>(
                        stream: controller.player.playerStateStream,
                        builder: (context, snapshot) {
                          final s = snapshot.data;
                          final loading = s?.processingState == ProcessingState.loading ||
                              s?.processingState == ProcessingState.buffering;
                          if (loading) {
                            return const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          }
                          final playing = s?.playing ?? false;
                          return IconButton(
                            icon: Icon(
                              playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            ),
                            iconSize: 36,
                            color: scheme.primary,
                            onPressed: controller.togglePlayPause,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        tooltip: 'السورة التالية',
                        onPressed: numero < 114 ? controller.next : null,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sourate.nomAr, style: Theme.of(context).textTheme.titleSmall),
                            Text(
                              '${QuranAudio.reciterNomAr} — ${QuranAudio.riwayaNomAr}',
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      ValueListenableBuilder<QuranPlaybackMode>(
                        valueListenable: controller.mode,
                        builder: (context, mode, __) {
                          final repeatOne = mode == QuranPlaybackMode.repeatOne;
                          return IconButton(
                            icon: Icon(repeatOne ? Icons.repeat_one : Icons.playlist_play),
                            color: repeatOne ? scheme.secondary : scheme.primary,
                            tooltip: repeatOne
                                ? 'إعادة هذه السورة فقط (اضغط للمتابعة إلى التي تليها)'
                                : 'متابعة إلى السورة التالية (اضغط لإعادة هذه السورة فقط)',
                            onPressed: controller.toggleMode,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'إيقاف',
                        onPressed: controller.stop,
                      ),
                    ],
                  ),
                  StreamBuilder<Duration>(
                    stream: controller.player.positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      final total = controller.player.duration ?? Duration.zero;
                      final max =
                          total.inMilliseconds > 0 ? total.inMilliseconds.toDouble() : 1.0;
                      final value =
                          position.inMilliseconds.clamp(0, max.toInt()).toDouble();
                      return Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            ),
                            child: Slider(
                              value: value,
                              max: max,
                              activeColor: scheme.secondary,
                              onChanged: total.inMilliseconds > 0
                                  ? (v) => controller.player.seek(Duration(milliseconds: v.toInt()))
                                  : null,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_fmt(position), style: Theme.of(context).textTheme.labelSmall),
                                Text(_fmt(total), style: Theme.of(context).textTheme.labelSmall),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
