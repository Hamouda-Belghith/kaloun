import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/models/sourate.dart';
import '../../core/services/quran_audio_controller.dart';
import 'listen_options_dialog.dart';

/// Panneau audio persistant : repliable (petite flèche, **toujours
/// visible**, même avant toute lecture) pour ne pas gêner la lecture,
/// bouton lecture/pause centré, verset en cours affiché, réglages de
/// répétition (verset/sourate, nombre de fois) accessibles via une icône
/// dédiée.
///
/// La visibilité (dépliée/repliée) est pilotée par
/// [QuranAudioController.panelExpanded] : la flèche la bascule
/// manuellement, et [QuranAudioController.showPanelTemporarily] (déclenché
/// par un tap ailleurs dans l'écran, ex. sur la page du Coran) l'ouvre et
/// la referme toute seule après quelques secondes.
///
/// [defaultSourate] est la sourate à utiliser quand rien n'est encore
/// chargé (ex. la sourate affichée dans le lecteur de pages) : permet de
/// démarrer l'écoute directement depuis le panneau replié, sans devoir
/// d'abord ouvrir la liste des sourates.
class AudioMiniPlayer extends StatelessWidget {
  const AudioMiniPlayer({super.key, required this.sourates, this.defaultSourate});

  final List<Sourate> sourates;
  final Sourate? defaultSourate;

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
        final isLoaded = numero != null;
        final Sourate? sourate =
            isLoaded ? sourates.firstWhere((s) => s.numero == numero) : defaultSourate;

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
                ValueListenableBuilder<bool>(
                  valueListenable: controller.panelExpanded,
                  builder: (context, expanded, __) {
                    return InkWell(
                      onTap: controller.togglePanel,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Icon(
                          expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                          color: scheme.tertiary,
                        ),
                      ),
                    );
                  },
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: controller.panelExpanded,
                  builder: (context, expanded, __) {
                    if (!expanded) return const SizedBox.shrink();
                    return sourate == null
                        ? const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Text('اختر سورة من القائمة للاستماع'),
                          )
                        : _ExpandedContent(
                            controller: controller,
                            sourate: sourate,
                            isLoaded: isLoaded,
                            fmt: _fmt,
                          );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExpandedContent extends StatelessWidget {
  const _ExpandedContent({
    required this.controller,
    required this.sourate,
    required this.isLoaded,
    required this.fmt,
  });

  final QuranAudioController controller;
  final Sourate sourate;
  final bool isLoaded;
  final String Function(Duration) fmt;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
              onPressed: isLoaded ? controller.previousAyah : null,
            ),
            StreamBuilder<PlayerState>(
              stream: controller.player.playerStateStream,
              builder: (context, snapshot) {
                final s = snapshot.data;
                final loading = isLoaded &&
                    (s?.processingState == ProcessingState.loading ||
                        s?.processingState == ProcessingState.buffering);
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
                final playing = isLoaded && (s?.playing ?? false);
                return IconButton(
                  icon: Icon(
                    playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  ),
                  iconSize: 44,
                  color: scheme.primary,
                  onPressed: isLoaded
                      ? controller.togglePlayPause
                      : () => controller.playSourate(sourate.numero),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_next),
              tooltip: 'الآية التالية',
              onPressed: isLoaded ? controller.nextAyah : null,
            ),
            Expanded(
              child: Align(
                child: IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'إيقاف',
                  onPressed: isLoaded ? controller.stop : null,
                ),
              ),
            ),
          ],
        ),
        ValueListenableBuilder<int?>(
          valueListenable: controller.currentAyah,
          builder: (context, ayah, __) {
            return Text(
              ayah != null ? '${sourate.nomAr} — الآية $ayah' : sourate.nomAr,
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
              final max = total.inMilliseconds > 0 ? total.inMilliseconds.toDouble() : 1.0;
              final value = position.inMilliseconds.clamp(0, max.toInt()).toDouble();
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
                        Text(fmt(position), style: Theme.of(context).textTheme.labelSmall),
                        Text(fmt(total), style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
