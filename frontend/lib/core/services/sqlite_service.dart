import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class SqliteService {
  static final SqliteService _instance = SqliteService._internal();
  factory SqliteService() => _instance;
  SqliteService._internal();

  static Database? _database;
  static SharedPreferences? _prefs;

  static const _permanentKeys = {
    'has_seen_onboarding',
    'sites_last_sync',
    'homestays_last_sync',
    'user_quiz_points',
  };

  Future<Database> get database async {
    if (kIsWeb) throw UnsupportedError('SQLite is not supported on Web. Use SharedPreferences methods.');
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<Database> _initDatabase() async {
    final dir  = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'lokyatra.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cache(
        key       TEXT PRIMARY KEY,
        value     TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
    debugPrint('SQLite database created');
  }


  Future<bool> isOnline() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (_) {
      return true;
    }
  }

  /// Checks if the API server itself is reachable (not just device connectivity).
  /// Uses the /health endpoint with a short timeout so it fails fast.
  Future<bool> isServerReachable() async {
    try {
      final response = await Dio().get(
        '${apiBaseUrl}health',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> put(String key, dynamic value) async {
    final timestamp = DateTime.now().toIso8601String();
    try {
      if (kIsWeb) {
        final p    = await prefs;
        final data = {'value': value, 'timestamp': timestamp};
        await p.setString(key, jsonEncode(data));
        debugPrint('Web put: $key');
        return;
      }

      final db      = await database;
      final jsonStr = jsonEncode(value);
      await db.insert(
        'cache',
        {'key': key, 'value': jsonStr, 'timestamp': timestamp},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('SQLite put: $key');
    } catch (e) {
      debugPrint('Cache put error ($key): $e');
    }
  }

  Future<dynamic> get(String key) async {
    try {
      if (kIsWeb) {
        final p   = await prefs;
        final str = p.getString(key);
        if (str != null) {
          final data = jsonDecode(str);
          return data['value'];
        }
        return null;
      }

      final db   = await database;
      final rows = await db.query('cache', where: 'key = ?', whereArgs: [key]);
      if (rows.isNotEmpty) return jsonDecode(rows.first['value'] as String);
    } catch (e) {
      debugPrint('Cache get error ($key): $e');
    }
    return null;
  }

  Future<void> delete(String key) async {
    try {
      if (kIsWeb) {
        final p = await prefs;
        await p.remove(key);
        return;
      }
      final db = await database;
      await db.delete('cache', where: 'key = ?', whereArgs: [key]);
    } catch (e) {
      debugPrint('Cache delete error ($key): $e');
    }
  }

  Future<List<dynamic>> getList(String key) async {
    final data = await get(key);
    return data is List ? data : [];
  }

  // ── Sites ─────────────────────────────────────────────────────────────────

  Future<void> cacheSites(List<dynamic> sites) async {
    await put('all_sites', sites);
    await put('sites_last_sync', DateTime.now().toIso8601String());
    debugPrint('Cached ${sites.length} sites');
  }

  Future<List<dynamic>> getCachedSites() => getList('all_sites');

  Future<bool> shouldRefreshSites({Duration maxAge = const Duration(hours: 24)}) async {
    final ts = await get('sites_last_sync');
    if (ts == null) return true;
    return DateTime.now().difference(DateTime.parse(ts as String)) > maxAge;
  }

  // ── Homestays ─────────────────────────────────────────────────────────────

  Future<void> cacheHomestays(List<dynamic> homestays) async {
    await put('all_homestays', homestays);
    await put('homestays_last_sync', DateTime.now().toIso8601String());
    debugPrint('Cached ${homestays.length} homestays');
  }

  Future<List<dynamic>> getCachedHomestays() => getList('all_homestays');

  Future<bool> shouldRefreshHomestays({Duration maxAge = const Duration(hours: 24)}) async {
    final ts = await get('homestays_last_sync');
    if (ts == null) return true;
    return DateTime.now().difference(DateTime.parse(ts as String)) > maxAge;
  }


  Future<void> cacheUserProfile(Map<String, dynamic> profile) async {
    await put('user_profile', profile);
    // Also keep legacy keys for backward compatibility with existing screens
    if (profile['name'] != null)         await put('user_name',  profile['name']);
    if (profile['email'] != null)        await put('user_email', profile['email']);
    if (profile['phoneNumber'] != null)  await put('user_phone',  profile['phoneNumber']);
    if (profile['profileImage'] != null) await put('user_image',  profile['profileImage']);
  }

  Future<Map<String, dynamic>?> getCachedUserProfile() async {
    final data = await get('user_profile');
    return data is Map<String, dynamic> ? data : null;
  }

  // ── Stories ───────────────────────────────────────────────────────────────

  Future<void> cacheStories(int siteId, List<dynamic> stories) async {
    await put('stories_$siteId', stories);
  }

  Future<List<dynamic>> getCachedStories(int siteId) => getList('stories_$siteId');

  // ── Cleanup ───────────────────────────────────────────────────────────────

  Future<void> deleteOldCache({int? daysOldOverride}) async {
    // Default to 7 days for Mobile, 3 days for Web
    final daysOldCap = daysOldOverride ?? (kIsWeb ? 3 : 7);
    final cutoff     = DateTime.now().subtract(Duration(days: daysOldCap));

    try {
      if (kIsWeb) {
        final p    = await prefs;
        final keys = p.getKeys();
        for (final key in keys) {
          if (_permanentKeys.contains(key)) continue;
          final str = p.getString(key);
          if (str == null) continue;
          try {
            final data = jsonDecode(str);
            final ts   = DateTime.tryParse(data['timestamp'] ?? '');
            if (ts != null && ts.isBefore(cutoff)) {
              await p.remove(key);
            }
          } catch (_) {}
        }
        return;
      }

      final db           = await database;
      final placeholders = _permanentKeys.map((_) => '?').join(', ');
      final whereArgs    = [cutoff.toIso8601String(), ..._permanentKeys];

      final count = await db.delete(
        'cache',
        where: 'timestamp < ? AND key NOT IN ($placeholders)',
        whereArgs: whereArgs,
      );
      debugPrint('Deleted $count old cache entries');
    } catch (e) {
      debugPrint('deleteOldCache error: $e');
    }
  }

  Future<void> clearAllCache() async {
    if (kIsWeb) {
      final p = await prefs;
      await p.clear();
      return;
    }
    final db = await database;
    await db.delete('cache');
    debugPrint('All cache cleared');
  }
}