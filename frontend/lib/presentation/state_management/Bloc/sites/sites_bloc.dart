import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/data/datasources/sites_remote_datasource.dart';
import 'sites_event.dart';
import 'sites_state.dart';

class SitesBloc extends Bloc<SitesEvent, SitesState> {
  final SitesRemoteDatasource _remote = SitesRemoteDatasource();

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
      final response = await _remote.getSites(q: event.query);
      final List sites = response.data ?? [];
      emit(SitesLoaded(sites));
    } catch (e) {
      emit(SitesError(_handleError(e)));
    }
  }

  Future<void> _onRefreshSites(RefreshSites event, Emitter<SitesState> emit) async {
    emit(SitesLoading());
    try {
      final response = await _remote.getSites();
      final List sites = response.data ?? [];
      emit(SitesLoaded(sites));
    } catch (e) {
      emit(SitesError(_handleError(e)));
    }
  }

  Future<void> _onLoadSiteById(LoadSiteById event, Emitter<SitesState> emit) async {
    emit(SiteDetailLoading());
    try {
      final response = await _remote.getSite(event.id);
      final site = response.data;
      emit(SiteDetailLoaded(site));
    } catch (e) {
      emit(SitesError(_handleError(e)));
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
