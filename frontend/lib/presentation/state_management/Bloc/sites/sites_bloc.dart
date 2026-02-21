import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:lokyatra_frontend/data/datasources/sites_remote_datasource.dart';
import 'package:lokyatra_frontend/data/repositories/sqlite_repository.dart';
import 'sites_event.dart';
import 'sites_state.dart';

class SitesBloc extends Bloc<SitesEvent, SitesState> {
  final SitesRemoteDatasource _remote = SitesRemoteDatasource();
  final SqliteRepository _repository = SqliteRepository();

  SitesBloc() : super(SitesInitial()) {
    on<LoadSites>(_onLoadSites);
    on<CreateSite>(_onCreateSite);
    on<RefreshSites>(_onRefreshSites);
    on<LoadSiteById>(_onLoadSiteById);
  }

  Future<void> _onLoadSites(LoadSites event, Emitter<SitesState> emit) async {
    debugPrint('LoadSites event triggered with query: ${event.query}');
    emit(SitesLoading());
    try {
      final sites = await _repository.getSites(query: event.query);
      debugPrint('Repository returned ${sites.length} sites');
      emit(SitesLoaded(sites));
    } catch (e, stackTrace) {
      debugPrint('Error in _onLoadSites: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(SitesError('Failed to load sites: $e'));
    }
  }

  Future<void> _onRefreshSites(RefreshSites event, Emitter<SitesState> emit) async {
    debugPrint('RefreshSites event triggered');
    emit(SitesLoading());
    try {
      // Force refresh from API by passing forceRefresh true
      final sites = await _repository.refreshSites(forceRefresh: true);
      debugPrint('Refresh returned ${sites.length} sites');
      emit(SitesLoaded(sites));
    } catch (e, stackTrace) {
      debugPrint('Error in _onRefreshSites: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(SitesError('Failed to refresh sites: $e'));
    }
  }

  Future<void> _onLoadSiteById(LoadSiteById event, Emitter<SitesState> emit) async {
    debugPrint('LoadSiteById event triggered for id: ${event.id}');
    emit(SiteDetailLoading());
    try {
      final site = await _repository.getSiteById(event.id);
      if (site != null) {
        debugPrint('Site found: ${site['name']}');
        emit(SiteDetailLoaded(site));
      } else {
        debugPrint('Site not found with id: ${event.id}');
        emit(SitesError('Site not found'));
      }
    } catch (e, stackTrace) {
      debugPrint('Error in _onLoadSiteById: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(SitesError('Failed to load site: $e'));
    }
  }

  Future<void> _onCreateSite(CreateSite event, Emitter<SitesState> emit) async {
    debugPrint('CreateSite event triggered');
    emit(SitesLoading());
    try {
      final resp = await _remote.createSite(fields: event.fields, files: event.files);
      debugPrint('Create site response status: ${resp.statusCode}');

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        debugPrint('Site created successfully, refreshing cache');
        await _repository.refreshSites(forceRefresh: true);
        emit(SiteCreateSuccess());
      } else {
        debugPrint('Create failed with status: ${resp.statusCode}');
        emit(SitesError('Failed to create site: ${resp.statusCode}'));
      }
    } catch (e, stackTrace) {
      debugPrint('Error in _onCreateSite: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(SitesError('Network error: $e'));
    }
  }
}