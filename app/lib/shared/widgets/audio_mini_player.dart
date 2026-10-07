import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/models/sourate.dart';
import '../../core/services/quran_audio_controller.dart';
import 'listen_options_dialog.dart';

/// Panneau audio persistant : repliable (petite flèche) pour ne pas gêner
/// la lecture, bouton lecture/pause centré, verset en cours affiché,
/// réglages de répétition (verset/sourate, nombre de fois) accessibles
/// via une icône dédiée.
class AudioMiniPlayer extends StatefulWidget {
  const AudioMiniPlayer({super.key, required this.sourates});

  final List<Sourate> sourates;

  @override
  State<AudioMiniPlayer> createState() => _AudioMiniPlayerState();
}

class _AudioMiniPlayerState extends State<AudioMiniPlayer> {
  bool _expanded = true;

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
        final sourate = widget.sourates.firstWhere((s) => s.numero == numero);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(top: BorderSide(color: scheme.tertiary, width: 1)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Icon(
                      _expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                      color: scheme.tertiary,
                    ),
                  ),
                ),
                if (_expanded) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          child: IconButton(
                            icon: const Icon(Icons.tune),
                            tooltip: 'إعدادات الاستماع',
                            onPressed: () => showListenOptionsDialog(
                              context,
                              sourate: sourate,
                              initialAyah: controller.currentAyah.value ?? 1,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        tooltip: 'الآية السابقة',
                        onPressed: controller.previousAyah,
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
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          }
                          final playing = s?.playing ?? false;
                          return IconButton(
                            icon: Icon(
                              playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            ),
                            iconSize: 44,
                            color: scheme.primary,
                            onPressed: controller.togglePlayPause,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        tooltip: 'الآية التالية',
                        onPressed: controller.nextAyah,
                      ),
                      Expanded(
                        child: Align(
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: 'إيقاف',
                            onPressed: controller.stop,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ValueListenableBuilder<int?>(
                    valueListenable: controller.currentAyah,
                    builder: (context, ayah, __) {
                      return Text(
                        ayah != null
                            ? '${sourate.nomAr} — الآية $ayah'
                            : sourate.nomAr,
                        style: Theme.of(context).textTheme.titleSmall,
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: StreamBuilder<Duration>(
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
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
