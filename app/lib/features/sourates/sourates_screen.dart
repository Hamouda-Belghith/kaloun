import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/models/sourate.dart';
import '../../core/services/quran_audio.dart';
import '../../shared/widgets/roundel.dart';

class SouratesScreen extends StatefulWidget {
  const SouratesScreen({super.key, required this.sourates});

  final List<Sourate> sourates;

  @override
  State<SouratesScreen> createState() => _SouratesScreenState();
}

class _SouratesScreenState extends State<SouratesScreen> {
  final _player = AudioPlayer();
  int? _activeSourateNumero;
  String? _error;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay(Sourate s) async {
    setState(() => _error = null);
    if (_activeSourateNumero == s.numero) {
      _player.playing ? await _player.pause() : await _player.play();
      return;
    }
    setState(() => _activeSourateNumero = s.numero);
    try {
      await _player.setUrl(QuranAudio.urlForSourate(s.numero));
      await _player.play();
    } catch (_) {
      setState(() {
        _error = 'تعذّر تحميل التلاوة. تحقق من اتصالك بالإنترنت.';
        _activeSourateNumero = null;
      });
    }
  }

  Future<void> _stop() async {
    await _player.stop();
    setState(() => _activeSourateNumero = null);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('السور')),
        body: Column(
          children: [
            if (_error != null)
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15),
                padding: const EdgeInsets.all(12),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            Expanded(
              child: ListView.separated(
                itemCount: widget.sourates.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, i) {
                  final s = widget.sourates[i];
                  final isActive = _activeSourateNumero == s.numero;
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
                        StreamBuilder<PlayerState>(
                          stream: _player.playerStateStream,
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
                              onPressed: () => _togglePlay(s),
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
            if (_activeSourateNumero != null)
              _MiniPlayer(
                player: _player,
                sourate: widget.sourates.firstWhere((s) => s.numero == _activeSourateNumero),
                onStop: _stop,
              ),
          ],
        ),
      ),
    );
  }
}

class _MiniPlayer extends StatelessWidget {
  const _MiniPlayer({required this.player, required this.sourate, required this.onStop});

  final AudioPlayer player;
  final Sourate sourate;
  final VoidCallback onStop;

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.tertiary, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  StreamBuilder<PlayerState>(
                    stream: player.playerStateStream,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing ?? false;
                      return IconButton(
                        icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_filled),
                        iconSize: 36,
                        color: scheme.primary,
                        onPressed: () => playing ? player.pause() : player.play(),
                      );
                    },
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
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'إيقاف',
                    onPressed: onStop,
                  ),
                ],
              ),
              StreamBuilder<Duration>(
                stream: player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final total = player.duration ?? Duration.zero;
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
                              ? (v) => player.seek(Duration(milliseconds: v.toInt()))
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
  }
}
