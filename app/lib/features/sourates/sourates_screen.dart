import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/models/sourate.dart';
import '../../core/services/quran_audio_controller.dart';
import '../../shared/widgets/audio_mini_player.dart';
import '../../shared/widgets/listen_options_dialog.dart';
import '../../shared/widgets/roundel.dart';

class SouratesScreen extends StatelessWidget {
  const SouratesScreen({super.key, required this.sourates});

  final List<Sourate> sourates;

  @override
  Widget build(BuildContext context) {
    final controller = QuranAudioController.instance;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('السور')),
        body: Column(
          children: [
            ValueListenableBuilder<String?>(
              valueListenable: controller.error,
              builder: (context, error, __) {
                if (error == null) return const SizedBox.shrink();
                return Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15),
                  padding: const EdgeInsets.all(12),
                  child: Text(error, textAlign: TextAlign.center),
                );
              },
            ),
            Expanded(
              child: ListView.separated(
                itemCount: sourates.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, i) {
                  final s = sourates[i];
                  return ListTile(
                    leading: Roundel(text: '${s.numero}'),
                    title: Text(s.nomAr, style: Theme.of(context).textTheme.titleMedium),
                    subtitle: Text(
                      '${s.nomFr} · ${s.nombreAyat} آية · '
                      '${s.estMecquoise ? "مكية" : "مدنية"}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.tune),
                          tooltip: 'إعدادات الاستماع',
                          onPressed: () => showListenOptionsDialog(context, sourate: s),
                        ),
                        ValueListenableBuilder<int?>(
                          valueListenable: controller.currentSourateNumero,
                          builder: (context, activeNumero, __) {
                            final isActive = activeNumero == s.numero;
                            return StreamBuilder<PlayerState>(
                              stream: controller.player.playerStateStream,
                              builder: (context, snapshot) {
                                final state = snapshot.data;
                                final loading = isActive &&
                                    (state?.processingState == ProcessingState.loading ||
                                        state?.processingState == ProcessingState.buffering);
                                final playing = isActive && (state?.playing ?? false);
                                if (loading) {
                                  return const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  );
                                }
                                return IconButton(
                                  icon: Icon(
                                    playing ? Icons.pause_circle_filled : Icons.play_circle_outline,
                                  ),
                                  color: Theme.of(context).colorScheme.secondary,
                                  tooltip: 'استماع',
                                  onPressed: () => controller.playSourate(s.numero),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ص ${s.pageDebut}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => Navigator.of(context).pop(s.pageDebut),
                  );
                },
              ),
            ),
            AudioMiniPlayer(sourates: sourates),
          ],
        ),
      ),
    );
  }
}
