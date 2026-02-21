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
  bool _connectivityWorking = true;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'lokyatra.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cache(
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    debugPrint('SQLite database created');
  }

  // Check internet connectivity with fallback
  Future<bool> isOnline() async {
    try {
      // Test connectivity plugin
      final connectivity = await Connectivity().checkConnectivity();
      final isConnected = connectivity != ConnectivityResult.none;
      debugPrint('Connectivity check: $isConnected');
      return isConnected;
    } catch (e) {
      // If plugin fails, assume online to not block functionality
      debugPrint('Connectivity plugin error: $e - assuming online');
      return true; // Assume online to allow API calls
    }
  }

  // ============== GENERIC JSON STORAGE ==============

  Future<void> put(String key, dynamic value) async {
    try {
      final db = await database;
      final jsonString = jsonEncode(value);
      final timestamp = DateTime.now().toIso8601String();

      await db.insert(
        'cache',
        {
          'key': key,
          'value': jsonString,
          'timestamp': timestamp,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('Saved: $key');
    } catch (e) {
      debugPrint('Error saving $key: $e');
    }
  }

  Future<dynamic> get(String key) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'cache',
        where: 'key = ?',
        whereArgs: [key],
      );

      if (maps.isNotEmpty) {
        return jsonDecode(maps.first['value']);
      }
    } catch (e) {
      debugPrint('Error getting $key: $e');
    }
    return null;
  }

  Future<List<dynamic>> getList(String key) async {
    final data = await get(key);
    return data is List ? data : [];
  }

  // ============== SITES CACHING ==============

  Future<void> cacheSites(List<dynamic> sites) async {
    await put('all_sites', sites);
    await put('sites_last_sync', DateTime.now().toIso8601String());
    debugPrint('Cached ${sites.length} sites');
  }

  Future<List<dynamic>> getCachedSites() async {
    return await getList('all_sites');
  }

  // Remove a specific site from cache
  Future<void> removeSiteFromCache(int siteId) async {
    try {
      final cachedSites = await getCachedSites();
      final updatedSites = cachedSites.where((site) {
        return site['id'] != siteId;
      }).toList();

      await cacheSites(updatedSites);
      debugPrint('Removed site $siteId from cache');
    } catch (e) {
      debugPrint('Error removing site from cache: $e');
    }
  }

  // ============== HOMESTAYS CACHING ==============

  Future<void> cacheHomestays(List<dynamic> homestays) async {
    await put('all_homestays', homestays);
    await put('homestays_last_sync', DateTime.now().toIso8601String());
    debugPrint('Cached ${homestays.length} homestays');
  }

  Future<List<dynamic>> getCachedHomestays() async {
    return await getList('all_homestays');
  }

  // ============== STORIES CACHING ==============

  Future<void> cacheStories(int siteId, List<dynamic> stories) async {
    await put('stories_$siteId', stories);
    debugPrint('Cached ${stories.length} stories for site $siteId');
  }

  Future<List<dynamic>> getCachedStories(int siteId) async {
    return await getList('stories_$siteId');
  }

  // ============== SYNC STATUS ==============

  Future<DateTime?> getSitesLastSync() async {
    final timeStr = await get('sites_last_sync');
    return timeStr != null ? DateTime.parse(timeStr) : null;
  }

  Future<DateTime?> getHomestaysLastSync() async {
    final timeStr = await get('homestays_last_sync');
    return timeStr != null ? DateTime.parse(timeStr) : null;
  }

  Future<bool> shouldRefreshSites({Duration maxAge = const Duration(hours: 24)}) async {
    final lastSync = await getSitesLastSync();
    if (lastSync == null) return true;
    return DateTime.now().difference(lastSync) > maxAge;
  }

  Future<bool> shouldRefreshHomestays({Duration maxAge = const Duration(hours: 24)}) async {
    final lastSync = await getHomestaysLastSync();
    if (lastSync == null) return true;
    return DateTime.now().difference(lastSync) > maxAge;
  }

  // ============== CLEAR CACHE ==============

  Future<void> clearAllCache() async {
    final db = await database;
    await db.delete('cache');
    debugPrint('All cache cleared');
  }

  // ============== DELETE OLD CACHE ==============

  Future<void> deleteOldCache({int daysOld = 7}) async {
    try {
      final db = await database;
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

      final count = await db.delete(
        'cache',
        where: "timestamp < ? AND key != 'sites_last_sync' AND key != 'homestays_last_sync'",
        whereArgs: [cutoffDate.toIso8601String()],
      );

      debugPrint('Deleted $count old cache entries');
    } catch (e) {
      debugPrint('Error deleting old cache: $e');
    }
  }
}