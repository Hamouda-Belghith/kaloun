import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/navigation_data.dart';

/// Charge et met en cache les métadonnées de navigation
/// (assets/data/navigation.json) : sourates, Juz', Hizb.
class NavigationDataService {
  NavigationDataService._();
  static final NavigationDataService instance = NavigationDataService._();

  NavigationData? _cached;

  Future<NavigationData> load() async {
    final cached = _cached;
    if (cached != null) return cached;
    final raw = await rootBundle.loadString('assets/data/navigation.json');
    final data = NavigationData.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    _cached = data;
    return data;
  }
}
