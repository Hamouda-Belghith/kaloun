import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/reader/reader_screen.dart';
import 'shared/theme/app_theme.dart';

/// Sur le web/desktop, Flutter n'active le glisser que pour le tactile par
/// défaut (souris exclue). Sur iPhone le swipe fonctionne nativement ; ce
/// comportement n'est là que pour rendre le web/desktop testable à la souris.
class _AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class MosshafQalounApp extends StatelessWidget {
  const MosshafQalounApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mosshaf Qaloun',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('fr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      scrollBehavior: _AppScrollBehavior(),
      home: const ReaderScreen(),
    );
  }
}
