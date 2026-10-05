import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Médaillon numéroté à liseré doré, qui reprend les repères visibles en
/// marge des pages scannées du Mosshaf (Juz', Hizb) plutôt qu'un avatar
/// Material générique.
class Roundel extends StatelessWidget {
  const Roundel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final gold = dark ? AppColors.goldDark : AppColors.gold;
    final ink = dark ? AppColors.inkDark : AppColors.ink;
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: gold, width: 1.4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: ink,
        ),
      ),
    );
  }
}
