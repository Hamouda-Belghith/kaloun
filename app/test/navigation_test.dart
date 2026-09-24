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
    await tester.ensureVisible(find.text(nomAr));
    await tester.pumpAndSettle();
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

  testWidgets('Al-Kahf affiche page_0294 (cartouche en bas de page)',
      (WidgetTester tester) async {
    final asset = await pageShownAfterTapping(tester, 'الكهف');
    expect(asset, 'assets/pages/page_0294.webp');
  });

  testWidgets('An-Nas (dernière sourate) affiche page_0605',
      (WidgetTester tester) async {
    final asset = await pageShownAfterTapping(tester, 'الناس');
    expect(asset, 'assets/pages/page_0605.webp');
  });

  String currentAsset(WidgetTester tester) {
    final imageFinder = find.byWidgetPredicate((widget) {
      if (widget is Image && widget.image is AssetImage) {
        return (widget.image as AssetImage).assetName.contains('page_');
      }
      return false;
    });
    final widget = tester.widget<Image>(imageFinder);
    return (widget.image as AssetImage).assetName;
  }

  testWidgets(
      "'Aller à la page' 2 affiche page_0003 (le numéro imprimé '2' correspond au fichier 3)",
      (WidgetTester tester) async {
    await tester.pumpWidget(const MosshafQalounApp());
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await tester.tap(find.byIcon(Icons.pin));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '2');
    await tester.tap(find.text('انتقال'));
    await tester.pumpAndSettle();

    expect(currentAsset(tester), 'assets/pages/page_0003.webp');
  });

  testWidgets(
      "Un signet sur la page imprimée 602 (fichier 603) s'affiche 'صفحة 602 - الكوثر'",
      (WidgetTester tester) async {
    await tester.pumpWidget(const MosshafQalounApp());
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Va sur la page imprimée 602 (fichier 603) via "Aller à la page".
    await tester.tap(find.byIcon(Icons.pin));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '602');
    await tester.tap(find.text('انتقال'));
    await tester.pumpAndSettle();
    expect(currentAsset(tester), 'assets/pages/page_0603.webp');

    // Ajoute un signet sur cette page, puis vérifie son libellé.
    await tester.tap(find.byIcon(Icons.bookmark));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.bookmark_add));
    await tester.pumpAndSettle();

    expect(find.text('صفحة 602 - الكوثر'), findsOneWidget);
  });

  testWidgets("'التعريف بالمصحف' affiche page_0606 (juste après la dernière page coranique)",
      (WidgetTester tester) async {
    await tester.pumpWidget(const MosshafQalounApp());
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await tester.tap(find.byIcon(Icons.pin));
    await tester.pumpAndSettle();
    await tester.tap(find.text('التعريف بالمصحف'));
    await tester.pumpAndSettle();

    expect(currentAsset(tester), 'assets/pages/page_0606.webp');
  });

  testWidgets(
      "La section تجويد liste les 3 résumés et ouvre l'image correspondante",
      (WidgetTester tester) async {
    await tester.pumpWidget(const MosshafQalounApp());
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await tester.tap(find.byIcon(Icons.account_tree_outlined));
    await tester.pumpAndSettle();

    expect(find.text('أحكام النون الساكنة والتنوين'), findsOneWidget);
    expect(find.text('أحكام الميم الساكنة'), findsOneWidget);
    expect(find.text('المدود'), findsOneWidget);

    await tester.tap(find.text('المدود'));
    await tester.pumpAndSettle();

    final imageFinder = find.byWidgetPredicate((widget) {
      if (widget is Image && widget.image is AssetImage) {
        return (widget.image as AssetImage).assetName.contains('tajwid/');
      }
      return false;
    });
    final widget = tester.widget<Image>(imageFinder);
    expect((widget.image as AssetImage).assetName, 'assets/tajwid/madd.webp');
  });

  testWidgets(
      "متن تحفة الأطفال (5 pages) : la 1ère page s'affiche et l'indicateur montre '1 / 5'",
      (WidgetTester tester) async {
    await tester.pumpWidget(const MosshafQalounApp());
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await tester.tap(find.byIcon(Icons.account_tree_outlined));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('متن تحفة الأطفال'), 200);
    await tester.tap(find.text('متن تحفة الأطفال'));
    await tester.pumpAndSettle();

    expect(find.text('1 / 5'), findsOneWidget);

    final imageFinder = find.byWidgetPredicate((widget) {
      if (widget is Image && widget.image is AssetImage) {
        return (widget.image as AssetImage).assetName.contains('tuhfat_atfal');
      }
      return false;
    });
    final widget = tester.widget<Image>(imageFinder);
    expect(
      (widget.image as AssetImage).assetName,
      'assets/tajwid/tuhfat_atfal_1.webp',
    );
  });
}
