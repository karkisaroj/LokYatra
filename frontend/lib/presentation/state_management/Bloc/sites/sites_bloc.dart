import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/data/datasources/sites_remote_datasource.dart';
import '../../../../core/services/sqlite_service.dart';
import '../../../../data/models/Site.dart';
import 'sites_event.dart';
import 'sites_state.dart';

class SitesBloc extends Bloc<SitesEvent, SitesState> {
  final SitesRemoteDatasource _remote = SitesRemoteDatasource();
  final SqliteService         _sqlite = SqliteService();

  List<CulturalSite>? _memCache;

  SitesBloc() : super(SitesInitial()) {
    on<LoadSites>(_onLoadSites);
    on<RefreshSites>(_onRefreshSites);
    on<LoadSiteById>(_onLoadSiteById);
    on<CreateSite>(_onCreateSite);
    on<UpdateSite>(_onUpdateSite);
    on<DeleteSite>(_onDeleteSite);
  }


  Future<void> _onLoadSites(LoadSites event, Emitter<SitesState> emit) async {
    emit(SitesLoading());

    final cached = await _sqlite.getCachedSites();
    if (cached.isNotEmpty) {
      final sites = _parseSites(cached);
      _memCache = sites;
      emit(SitesLoaded(sites));
    }

    final isOnline = await _sqlite.isOnline();
    if (!isOnline) {
      if (cached.isEmpty) emit(const SitesError('No internet connection and no cached data.'));
      return;
    }

    try {
      final resp = await _remote.getSites(q: event.query);
      if (resp.statusCode == 200 && resp.data != null) {
        final raw   = resp.data as List<dynamic>;
        final sites = _parseSites(raw);
        _memCache = sites;
        await _sqlite.cacheSites(raw);
        emit(SitesLoaded(sites));
      } else {
        if (cached.isEmpty) emit(SitesError('Failed to load sites: ${resp.statusCode}'));
      }
    } catch (e) {
      debugPrint('SitesBloc LoadSites error: $e');
      if (cached.isEmpty) emit(SitesError('Network error. Showing cached data.'));
    }
  }


  Future<void> _onRefreshSites(RefreshSites event, Emitter<SitesState> emit) async {
    emit(SitesLoading());
    final isOnline = await _sqlite.isOnline();
    if (!isOnline) {
      final cached = await _sqlite.getCachedSites();
      if (cached.isNotEmpty) {
        final sites = _parseSites(cached);
        _memCache = sites;
        emit(SitesLoaded(sites));
      } else {
        emit(const SitesError('No internet connection.'));
      }
      return;
    }

    try {
      final resp = await _remote.getSites();
      if (resp.statusCode == 200 && resp.data != null) {
        final raw   = resp.data as List<dynamic>;
        final sites = _parseSites(raw);
        _memCache = sites;
        await _sqlite.cacheSites(raw);
        emit(SitesLoaded(sites));
      } else {
        final cached = await _sqlite.getCachedSites();
        if (cached.isNotEmpty) {
          final sites = _parseSites(cached);
          _memCache = sites;
          emit(SitesLoaded(sites));
        } else {
          emit(SitesError('Refresh failed: ${resp.statusCode}'));
        }
      }
    } catch (e) {
      // Server unreachable — fall back to cached data
      final cached = await _sqlite.getCachedSites();
      if (cached.isNotEmpty) {
        final sites = _parseSites(cached);
        _memCache = sites;
        emit(SitesLoaded(sites));
      } else if (_memCache != null) {
        emit(SitesLoaded(_memCache!));
      } else {
        emit(const SitesError('Unable to connect. Please check your network.'));
      }
    }
  }


  Future<void> _onLoadSiteById(LoadSiteById event, Emitter<SitesState> emit) async {
    emit(SiteDetailLoading());

    final isOnline = await _sqlite.isOnline();

    if (!isOnline) {
      final fromCache = await _siteFromCache(event.id);
      if (fromCache != null) {
        emit(SiteDetailLoaded(fromCache));
      } else {
        emit(const SiteDetailError('No internet and site not cached.'));
      }
      if (_memCache != null) emit(SitesLoaded(_memCache!));
      return;
    }

    try {
      final resp = await _remote.getSite(event.id);
      if (resp.statusCode == 200 && resp.data != null) {
        dynamic raw = resp.data;
        if (raw is String) raw = jsonDecode(raw);
        final site = CulturalSite.fromJson(raw as Map<String, dynamic>);

        await _upsertSiteInCache(raw);

        emit(SiteDetailLoaded(site));
      } else {
        final fromCache = await _siteFromCache(event.id);
        if (fromCache != null) {
          emit(SiteDetailLoaded(fromCache));
        } else {
          emit(SiteDetailError('Failed: ${resp.statusCode}'));
        }
      }
    } catch (e) {
      final fromCache = await _siteFromCache(event.id);
      if (fromCache != null) {
        emit(SiteDetailLoaded(fromCache));
      } else {
        emit(SiteDetailError('Network error: $e'));
      }
    }

    if (_memCache != null) emit(SitesLoaded(_memCache!));
  }

  //Admin CRUD

  Future<void> _onCreateSite(CreateSite event, Emitter<SitesState> emit) async {
    emit(SitesLoading());
    try {
      final resp = await _remote.createSite(fields: event.fields, files: event.files);
      if (resp.statusCode == 201 || resp.statusCode == 200) {
        emit(SiteCreateSuccess());
        add(const RefreshSites());
      } else {
        emit(SitesError('Failed to create: ${resp.statusCode}'));
      }
    } catch (e) {
      emit(SitesError('$e'));
    }
  }

  Future<void> _onUpdateSite(UpdateSite event, Emitter<SitesState> emit) async {
    emit(SitesLoading());
    try {
      final resp = await _remote.updateSite(id: event.id, fields: event.fields, files: event.files);
      if (resp.statusCode == 200 || resp.statusCode == 204) {
        emit(SiteCreateSuccess());
        add(const RefreshSites());
      } else {
        emit(SitesError('Failed to update: ${resp.statusCode}'));
      }
    } catch (e) {
      emit(SitesError('$e'));
    }
  }

  Future<void> _onDeleteSite(DeleteSite event, Emitter<SitesState> emit) async {
    // Snapshot current list before loading so we can restore on failure
    final snapshot = _memCache != null ? List<CulturalSite>.from(_memCache!) : null;

    // Check server reachability before attempting — gives a clear error message
    final serverUp = await _sqlite.isServerReachable();
    if (!serverUp) {
      emit(const SitesError('Server is currently unavailable. Please try again in a moment.'));
      if (snapshot != null) emit(SitesLoaded(snapshot));
      return;
    }

    emit(SitesLoading());
    try {
      final resp = await _remote.deleteSite(event.id);
      if (resp.statusCode == 200 || resp.statusCode == 204) {
        await _removeSiteFromCache(event.id);
        add(const RefreshSites());
      } else {
        if (snapshot != null) {
          _memCache = snapshot;
          emit(SitesLoaded(snapshot));
        }
        emit(SitesError('Failed to delete: ${resp.statusCode}'));
      }
    } catch (e) {
      if (snapshot != null) {
        _memCache = snapshot;
        emit(SitesLoaded(snapshot));
      } else {
        final cached = await _sqlite.getCachedSites();
        if (cached.isNotEmpty) {
          final sites = _parseSites(cached);
          _memCache = sites;
          emit(SitesLoaded(sites));
        }
      }
      emit(const SitesError('Delete failed. Server may be temporarily unavailable.'));
    }
  }

//helper methods
  List<CulturalSite> _parseSites(List<dynamic> raw) =>
      raw.map((e) => CulturalSite.fromJson(e as Map<String, dynamic>)).toList();

  Future<CulturalSite?> _siteFromCache(int id) async {
    final all = await _sqlite.getCachedSites();
    final map = all.firstWhere(
          (s) => (s as Map<String, dynamic>)['id'] == id,
      orElse: () => null,
    );
    if (map == null) return null;
    return CulturalSite.fromJson(map as Map<String, dynamic>);
  }

  Future<void> _upsertSiteInCache(Map<String, dynamic> siteJson) async {
    final all = await _sqlite.getCachedSites();
    final updated = all.map((s) {
      return (s as Map<String, dynamic>)['id'] == siteJson['id'] ? siteJson : s;
    }).toList();
    if (!all.any((s) => (s as Map<String, dynamic>)['id'] == siteJson['id'])) {
      updated.add(siteJson);
    }
    await _sqlite.cacheSites(updated);
  }

  Future<void> _removeSiteFromCache(int id) async {
    final all     = await _sqlite.getCachedSites();
    final updated = all.where((s) => (s as Map<String, dynamic>)['id'] != id).toList();
    await _sqlite.cacheSites(updated);
  }
}