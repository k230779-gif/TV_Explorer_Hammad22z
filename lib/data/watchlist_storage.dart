import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:assignment_2_k230779_hammad/domain/show.dart';

class WatchlistStorage {
  static const String _key = 'watchlist_shows';

  Future<List<Show>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final shows = <Show>[];

    for (final item in raw) {
      try {
        shows.add(Show.fromJson(jsonDecode(item) as Map<String, dynamic>));
      } catch (_) {
        // skip a corrupted entry instead of crashing
      }
    }
    return shows;
  }

  Future<void> save(List<Show> shows) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      shows.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }
}