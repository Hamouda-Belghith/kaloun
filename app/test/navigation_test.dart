import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mosshaf_qaloun/app.dart';

/// Une sourate peut commencer au milieu d'une page si la précédente est
/// courte (ex. Al-Fatiha + Al-Baqara partagent la page 3). Ce test vérifie
/// qu'un tap sur une sourate affiche bien sa page de début exacte.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<String> pageShownAfterTapping(WidgetTester tester, String nomAr) async {
    await tester.pumpWidget(const MosshafQalounApp());
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await tester.tap(find.byIcon(Icons.menu_book));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text(nomAr), 200);
    await tester.tap(find.text(nomAr));
    await tester.pumpAndSettle();

    final imageFinder = find.byWidgetPredicate((widget) {
      if (widget is Image && widget.image is AssetImage) {
        return (widget.image as AssetImage).assetName.contains('page_');
      }
      return false;
    });
    final widget = tester.widget<Image>(imageFinder);
    return (widget.image as AssetImage).assetName;
  }

  testWidgets('Al-Baqara affiche page_0003 (partagée avec la fin de Al-Fatiha)',
      (WidgetTester tester) async {
    final asset = await pageShownAfterTapping(tester, 'البقرة');
    expect(asset, 'assets/pages/page_0003.webp');
  });

  testWidgets('An-Nas (dernière sourate) affiche page_0605',
      (WidgetTester tester) async {
    final asset = await pageShownAfterTapping(tester, 'الناس');
    expect(asset, 'assets/pages/page_0605.webp');
  });
}
