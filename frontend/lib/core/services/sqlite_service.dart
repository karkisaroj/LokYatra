import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class SqliteService {
  static final SqliteService _instance = SqliteService._internal();
  factory SqliteService() => _instance;
  SqliteService._internal();

  static Database? _database;

  // Keys that must never be auto-deleted
  static const _permanentKeys = {
    'has_seen_onboarding',
    'sites_last_sync',
    'homestays_last_sync',
  };

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
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

  Future<void> put(String key, dynamic value) async {
    try {
      final db        = await database;
      final jsonStr   = jsonEncode(value);
      final timestamp = DateTime.now().toIso8601String();
      await db.insert(
        'cache',
        {'key': key, 'value': jsonStr, 'timestamp': timestamp},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('SQLite put: $key');
    } catch (e) {
      debugPrint('SQLite put error ($key): $e');
    }
  }

  Future<dynamic> get(String key) async {
    try {
      final db   = await database;
      final rows = await db.query('cache', where: 'key = ?', whereArgs: [key]);
      if (rows.isNotEmpty) return jsonDecode(rows.first['value'] as String);
    } catch (e) {
      debugPrint('SQLite get error ($key): $e');
    }
    return null;
  }

  Future<void> delete(String key) async {
    try {
      final db = await database;
      await db.delete('cache', where: 'key = ?', whereArgs: [key]);
    } catch (e) {
      debugPrint('SQLite delete error ($key): $e');
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

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<void> cacheUserProfile({
    required String name,
    required String email,
    String? phone,
    String? profileImage,
  }) async {
    await put('user_name',  name);
    await put('user_email', email);
    if (phone        != null) await put('user_phone',         phone);
    if (profileImage != null) await put('user_profile_image', profileImage);
  }

  // ── Stories ───────────────────────────────────────────────────────────────

  Future<void> cacheStories(int siteId, List<dynamic> stories) async {
    await put('stories_$siteId', stories);
  }

  Future<List<dynamic>> getCachedStories(int siteId) => getList('stories_$siteId');

  // ── Cleanup ───────────────────────────────────────────────────────────────

  Future<void> deleteOldCache({int daysOld = 7}) async {
    try {
      final db         = await database;
      final cutoff     = DateTime.now().subtract(Duration(days: daysOld)).toIso8601String();

      // Build exclusion list dynamically from _permanentKeys
      final placeholders = _permanentKeys.map((_) => '?').join(', ');
      final whereArgs    = [cutoff, ..._permanentKeys];

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
    final db = await database;
    await db.delete('cache');
    debugPrint('All cache cleared');
  }
}