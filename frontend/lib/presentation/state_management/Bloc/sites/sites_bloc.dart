import 'package:bloc/bloc.dart';
import 'package:lokyatra_frontend/data/datasources/sites_remote_datasource.dart';
import 'sites_event.dart';
import 'sites_state.dart';

class SitesBloc extends Bloc<SitesEvent, SitesState> {
  final SitesRemoteDatasource _remote = SitesRemoteDatasource();

  SitesBloc() : super(SitesInitial()) {
    on<LoadSites>(_onLoadSites);
    on<CreateSite>(_onCreateSite);
  }

  Future<void> _onLoadSites(LoadSites event, Emitter<SitesState> emit) async {
    emit(SitesLoading());
    try {
      final resp = await _remote.getSites(q: event.query);
      if (resp.statusCode == 200) {
        final data = resp.data as List<dynamic>;
        emit(SitesLoaded(data));
      } else {
        emit(SitesError('Failed to load sites: ${resp.statusCode}'));
      }
    } catch (e) {
      emit(SitesError('Network error: $e'));
    }
  }

  Future<void> _onCreateSite(CreateSite event, Emitter<SitesState> emit) async {
    emit(SitesLoading());
    try {
      final resp = await _remote.createSite(fields: event.fields, files: event.files);
      if (resp.statusCode == 201 || resp.statusCode == 200) {
        emit(SiteCreateSuccess());
        // Optionally chain a reload; keep separate to let UI decide
      } else {
        emit(SitesError('Failed to create site: ${resp.statusCode}'));
      }
    } catch (e) {
      emit(SitesError('Network error: $e'));
    }
  }
}