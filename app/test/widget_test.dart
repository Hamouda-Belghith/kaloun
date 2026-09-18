import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mosshaf_qaloun/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('L\'app démarre et affiche un indicateur de chargement',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MosshafQalounApp());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets(
      'Après chargement, le lecteur affiche la page 1 avec sa barre de navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MosshafQalounApp());
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(BottomAppBar), findsOneWidget);
    expect(find.byIcon(Icons.menu_book), findsOneWidget);
  });
}
