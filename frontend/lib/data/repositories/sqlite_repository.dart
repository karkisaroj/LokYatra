import 'package:flutter/foundation.dart';
import '../../core/services/sqlite_service.dart';
import '../datasources/sites_remote_datasource.dart';

class SqliteRepository {
  final SqliteService _sqlite = SqliteService();
  final SitesRemoteDatasource _remote = SitesRemoteDatasource();

  // Get sites with cache + network strategy
  Future<List<dynamic>> getSites({String? query}) async {
    try {
      final isOnline = await _sqlite.isOnline();
      final shouldRefresh = await _sqlite.shouldRefreshSites();

      // Get cached sites first
      final cachedSites = await _sqlite.getCachedSites();
      debugPrint('Found ${cachedSites.length} cached sites');

      // Filter cached sites by query if needed
      final filteredCached = _filterSitesByQuery(cachedSites, query);

      // If offline, return cached data immediately
      if (!isOnline) {
        debugPrint('OFFLINE: Returning ${filteredCached.length} cached sites');
        return filteredCached;
      }

      // If we have cached data and no refresh needed, return it and refresh in background
      if (filteredCached.isNotEmpty && !shouldRefresh) {
        debugPrint('Using ${filteredCached.length} cached sites (refresh in background)');
        _refreshSitesInBackground(query);
        return filteredCached;
      }

      // If we have cached data but need refresh, show it while fetching new
      if (filteredCached.isNotEmpty) {
        debugPrint('Showing cached sites while fetching new');
        _refreshSitesInBackground(query);
        return filteredCached;
      }

      // No cache, fetch from API
      debugPrint('No cache, fetching from API');
      return await _fetchSitesFromApi(query);

    } catch (e) {
      debugPrint('Error in getSites: $e');
      // If anything fails, try to return whatever is in cache
      final cachedSites = await _sqlite.getCachedSites();
      return _filterSitesByQuery(cachedSites, query);
    }
  }

  // Force refresh from API
  Future<List<dynamic>> refreshSites({String? query, bool forceRefresh = false}) async {
    try {
      debugPrint('Force refreshing sites from API');
      final response = await _remote.getSites(q: query);

      if (response.statusCode == 200) {
        final sites = response.data as List<dynamic>;
        debugPrint('API returned ${sites.length} sites');

        // Cache the fresh data
        await _sqlite.cacheSites(sites);

        return _filterSitesByQuery(sites, query);
      } else {
        debugPrint('API failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Force refresh failed: $e');
    }

    // If API fails, return cached data
    final cachedSites = await _sqlite.getCachedSites();
    return _filterSitesByQuery(cachedSites, query);
  }

  // Get single site by ID
  Future<dynamic> getSiteById(int id) async {
    try {
      final isOnline = await _sqlite.isOnline();

      // Try cache first
      final cachedSites = await _sqlite.getCachedSites();
      final cachedSite = cachedSites.firstWhere(
            (site) => site['id'] == id,
        orElse: () => null,
      );

      // If offline, return cached
      if (!isOnline) {
        return cachedSite;
      }

      // If online, fetch fresh data
      try {
        debugPrint('Fetching site $id from API');
        final response = await _remote.getSite(id);
        if (response.statusCode == 200) {
          final site = response.data;

          // Update cache with this site
          final updatedSites = cachedSites.map((s) {
            return s['id'] == id ? site : s;
          }).toList();

          if (!cachedSites.any((s) => s['id'] == id)) {
            updatedSites.add(site);
          }

          await _sqlite.cacheSites(updatedSites);
          return site;
        }
      } catch (e) {
        debugPrint('Error fetching site $id: $e');
      }

      return cachedSite;

    } catch (e) {
      debugPrint('Error in getSiteById: $e');
      return null;
    }
  }

  // Private: Fetch sites from API and cache them
  Future<List<dynamic>> _fetchSitesFromApi(String? query) async {
    try {
      debugPrint('Fetching sites from API');
      final response = await _remote.getSites(q: query);

      if (response.statusCode == 200) {
        final sites = response.data as List<dynamic>;
        debugPrint('API returned ${sites.length} sites');
        await _sqlite.cacheSites(sites);
        return sites;
      } else {
        debugPrint('API failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching sites: $e');
    }
    return [];
  }

  // Private: Refresh in background
  Future<void> _refreshSitesInBackground(String? query) async {
    try {
      final response = await _remote.getSites(q: query);
      if (response.statusCode == 200) {
        final sites = response.data as List<dynamic>;
        await _sqlite.cacheSites(sites);
        debugPrint('Background refresh completed');
      }
    } catch (e) {
      debugPrint('Background refresh failed: $e');
    }
  }

  // Private: Filter sites by query
  List<dynamic> _filterSitesByQuery(List<dynamic> sites, String? query) {
    if (query == null || query.isEmpty) return sites;

    return sites.where((site) {
      final name = site['name']?.toString().toLowerCase() ?? '';
      final category = site['category']?.toString().toLowerCase() ?? '';
      final district = site['district']?.toString().toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();

      return name.contains(searchQuery) ||
          category.contains(searchQuery) ||
          district.contains(searchQuery);
    }).toList();
  }
}