import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/data/datasources/sites_remote_datasource.dart';
import '../../../../data/models/Site.dart';
import 'sites_event.dart';
import 'sites_state.dart';

class SitesBloc extends Bloc<SitesEvent, SitesState> {
  final SitesRemoteDatasource _remote = SitesRemoteDatasource();
  List<CulturalSite>? _cachedSites;

  SitesBloc() : super(SitesInitial()) {
    on<LoadSites>(_onLoadSites);
    on<CreateSite>(_onCreateSite);
    on<RefreshSites>(_onRefreshSites);
    on<LoadSiteById>(_onLoadSiteById);
    on<UpdateSite>(_onUpdateSite);
    on<DeleteSite>(_onDeleteSite);
  }

  String _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 500) {
          return 'Server error (500). Please try again later.';
        }
        return 'Request failed: $statusCode. ${e.response?.statusMessage ?? ''}';
      }
      return 'Network error: ${e.message}';
    }
    return 'An unexpected error occurred: $e';
  }

  Future<void> _onLoadSites(LoadSites event, Emitter<SitesState> emit) async {
    emit(SitesLoading());
    try {
      final resp = await _remote.getSites();
      if (resp.statusCode == 200 && resp.data != null) {
        final raw = resp.data as List<dynamic>;
        final sites = raw
            .map((e) => CulturalSite.fromJson(e as Map<String, dynamic>))
            .toList();
        _cachedSites = sites;
        emit(SitesLoaded(sites));
      } else {
        emit(SitesError('Failed to load sites: ${resp.statusCode}'));
      }
    } catch (e) {
      emit(SitesError(_handleError(e)));
    }
  }

  Future<void> _onRefreshSites(RefreshSites event, Emitter<SitesState> emit) async {
    emit(SitesLoading());
    try {
      final response = await _remote.getSites();
      if (response.statusCode == 200 && response.data != null) {
        final raw = response.data as List<dynamic>;
        final sites = raw
            .map((e) => CulturalSite.fromJson(e as Map<String, dynamic>))
            .toList();
        _cachedSites = sites;
        emit(SitesLoaded(sites));
      } else {
        emit(SitesError('Failed to refresh sites: ${response.statusCode}'));
      }
    } catch (e) {
      emit(SitesError(_handleError(e)));
    }
  }

  Future<void> _onLoadSiteById(LoadSiteById event, Emitter<SitesState> emit) async {
    emit(SiteDetailLoading());
    try {
      final resp = await _remote.getSite(event.id);

      if (resp.statusCode == 200 && resp.data != null) {
        dynamic raw = resp.data;

        // Handle both Map and String cases
        if (raw is String) {
          raw = jsonDecode(raw);
        }

        final site = CulturalSite.fromJson(raw as Map<String, dynamic>);
        emit(SiteDetailLoaded(site));

        // Optionally re-emit cached list so UI still has sites list
        if (_cachedSites != null) {
          emit(SitesLoaded(_cachedSites!));
        }
      } else {
        emit(SiteDetailError('Failed to load site: ${resp.statusCode}'));
        if (_cachedSites != null) emit(SitesLoaded(_cachedSites!));
      }
    } catch (e) {
      emit(SiteDetailError(_handleError(e)));
      if (_cachedSites != null) emit(SitesLoaded(_cachedSites!));
    }
  }

  Future<void> _onCreateSite(CreateSite event, Emitter<SitesState> emit) async {
    emit(SitesLoading());
    try {
      final response = await _remote.createSite(fields: event.fields, files: event.files);
      if (response.statusCode == 201 || response.statusCode == 200) {
        emit(SiteCreateSuccess());
        add(const RefreshSites());
      } else {
        emit(SitesError('Failed to create site: ${response.statusCode}'));
      }
    } catch (e) {
      emit(SitesError(_handleError(e)));
    }
  }

  Future<void> _onUpdateSite(UpdateSite event, Emitter<SitesState> emit) async {
    emit(SitesLoading());
    try {
      final response = await _remote.updateSite(
        id: event.id,
        fields: event.fields,
        files: event.files,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        emit(SiteCreateSuccess());
        add(const RefreshSites());
      } else {
        emit(SitesError('Failed to update site: ${response.statusCode}'));
      }
    } catch (e) {
      emit(SitesError(_handleError(e)));
    }
  }

  Future<void> _onDeleteSite(DeleteSite event, Emitter<SitesState> emit) async {
    emit(SitesLoading());
    try {
      final response = await _remote.deleteSite(event.id);
      if (response.statusCode == 200 || response.statusCode == 204) {
        add(const RefreshSites());
      } else {
        emit(SitesError('Failed to delete site: ${response.statusCode}'));
      }
    } catch (e) {
      emit(SitesError(_handleError(e)));
    }
  }
}