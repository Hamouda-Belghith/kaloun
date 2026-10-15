import 'package:flutter/material.dart';
import '../../core/models/sourate.dart';
import '../../core/services/quran_audio_controller.dart';

/// Boîte de dialogue : choisir le verset de départ, le nombre de
/// répétitions, et si la répétition porte sur le verset seul ou sur
/// la sourate (à partir de ce verset).
Future<void> showListenOptionsDialog(
  BuildContext context, {
  required Sourate sourate,
  int initialAyah = 1,
}) async {
  final ayahController = TextEditingController(text: '$initialAyah');
  final countController =
      TextEditingController(text: '${QuranAudioController.instance.repeatCount.value}');
  var scope = QuranAudioController.instance.repeatScope.value;

  // Le texte par défaut (ex. "1") doit disparaître dès le premier focus
  // sur le champ, pas seulement quand l'utilisateur l'efface à la main.
  var ayahCleared = false;
  final ayahFocusNode = FocusNode();
  var countCleared = false;
  final countFocusNode = FocusNode();
  ayahFocusNode.addListener(() {
    if (ayahFocusNode.hasFocus && !ayahCleared) {
      ayahCleared = true;
      ayahController.clear();
    }
  });
  countFocusNode.addListener(() {
    if (countFocusNode.hasFocus && !countCleared) {
      countCleared = true;
      countController.clear();
    }
  });

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      String? error;
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Text('إعدادات الاستماع — ${sourate.nomAr}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: ayahController,
                    focusNode: ayahFocusNode,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'ابدأ من آية (1 - ${sourate.nombreAyat})',
                      errorText: error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: countController,
                    focusNode: countFocusNode,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'عدد التكرارات'),
                  ),
                  const SizedBox(height: 16),
                  const Text('التكرار يشمل:'),
                  const SizedBox(height: 4),
                  SegmentedButton<RepeatScope>(
                    segments: const [
                      ButtonSegment(value: RepeatScope.ayah, label: Text('الآية فقط')),
                      ButtonSegment(value: RepeatScope.sourate, label: Text('السورة')),
                    ],
                    selected: {scope},
                    onSelectionChanged: (s) => setState(() => scope = s.first),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () {
                    final ayah = int.tryParse(ayahController.text);
                    final count = int.tryParse(countController.text);
                    if (ayah == null || ayah < 1 || ayah > sourate.nombreAyat) {
                      setState(() => error = 'أدخل رقمًا بين 1 و ${sourate.nombreAyat}');
                      return;
                    }
                    if (count == null || count < 1) {
                      setState(() => error = 'عدد التكرارات غير صالح');
                      return;
                    }
                    QuranAudioController.instance
                        .setRepeatOptions(scope: scope, count: count);
                    Navigator.of(dialogContext).pop(true);
                    QuranAudioController.instance.playSourateFromAyah(sourate.numero, ayah);
                  },
                  child: const Text('ابدأ'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
  ayahFocusNode.dispose();
  countFocusNode.dispose();
}
