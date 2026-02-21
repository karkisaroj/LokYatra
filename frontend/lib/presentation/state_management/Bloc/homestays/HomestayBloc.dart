import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/data/datasources/homestays_remote_datasource.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';
import 'HomestayEvent.dart';
import 'HomestayState.dart';

class HomestayBloc extends Bloc<HomestayEvent, HomestayState> {
  final HomestaysRemoteDatasource _datasource = HomestaysRemoteDatasource();

  HomestayBloc() : super(const HomestayInitial()) {
    on<OwnerLoadMyHomestays>(_onOwnerLoadMyHomestays);
    on<OwnerUpdateHomestay>(_onOwnerUpdateHomestay);
    on<TouristLoadAllHomestays>(_onTouristLoadAllHomestays);
    on<TouristLoadHomestaysNearSite>(_onTouristLoadHomestaysNearSite);
    on<ResetHomestayState>(_onResetHomestayState);
    on<AdminDeleteHomestay>(_onAdminDeleteHomestay);
    on<AdminToggleHomestayVisibility>(_onAdminToggleHomestayVisibility);
  }

  Future<void> _onOwnerLoadMyHomestays(OwnerLoadMyHomestays event, Emitter<HomestayState> emit) async {
    emit(const HomestayLoading());
    try {
      final response = await _datasource.getMyHomestays();
      if (response.statusCode == 200) {
        final List data = response.data;
        final homestays = data.map((json) => Homestay.fromJson(json)).toList();
        emit(OwnerHomestaysLoaded(homestays));
      } else {
        emit(HomestayError('Failed to load: ${response.statusCode}'));
      }
    } catch (e) {
      emit(HomestayError('Network error: $e'));
    }
  }

  Future<void> _onOwnerUpdateHomestay(OwnerUpdateHomestay event, Emitter<HomestayState> emit) async {
    emit(const HomestayLoading());
    try {
      final response = await _datasource.updateHomestay(
        id: event.id, fields: event.fields, files: event.files,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        add(const OwnerLoadMyHomestays());
      } else {
        emit(HomestayError('Failed to update: ${response.statusCode}'));
      }
    } catch (e) {
      emit(HomestayError('Network error: $e'));
    }
  }

  Future<void> _onTouristLoadAllHomestays(TouristLoadAllHomestays event, Emitter<HomestayState> emit) async {
    emit(const HomestayLoading());
    try {
      final response = await _datasource.getAllHomestays();
      if (response.statusCode == 200) {
        final List data = response.data;
        final homestays = data.map((j) => Homestay.fromJson(j)).toList();
        emit(TouristAllHomestaysLoaded(homestays));
      } else {
        emit(HomestayError('Failed to load homestays: ${response.statusCode}'));
      }
    } catch (e) {
      emit(HomestayError('Network error: $e'));
    }
  }

  Future<void> _onTouristLoadHomestaysNearSite(TouristLoadHomestaysNearSite event, Emitter<HomestayState> emit) async {
    emit(const HomestayLoading());
    try {
      final response = await _datasource.getAllHomestays();
      if (response.statusCode == 200) {
        final List data = response.data;
        final all = data.map((j) => Homestay.fromJson(j)).toList();
        final nearby = all.where((h) {
          if (!h.isVisible) return false;
          final siteName = h.nearCulturalSite?.name.toLowerCase() ?? '';
          return siteName.contains(event.siteName.toLowerCase());
        }).toList();
        emit(TouristNearbyHomestaysLoaded(nearby, event.siteName));
      } else {
        emit(HomestayError('Failed to load: ${response.statusCode}'));
      }
    } catch (e) {
      emit(HomestayError('Network error: $e'));
    }
  }

  Future<void> _onResetHomestayState(ResetHomestayState event, Emitter<HomestayState> emit) async {
    emit(const HomestayInitial());
  }

  // ── NEW: Admin Event Handlers ──
  Future<void> _onAdminDeleteHomestay(AdminDeleteHomestay event, Emitter<HomestayState> emit) async {
    emit(const HomestayLoading());
    try {
      final response = await _datasource.deleteHomestay(event.id);
      if (response.statusCode == 200 || response.statusCode == 204) {
        add(const TouristLoadAllHomestays());
      } else {
        emit(HomestayError('Failed to delete: ${response.statusCode}'));
      }
    } catch (e) {
      emit(HomestayError('Network error: $e'));
    }
  }

  Future<void> _onAdminToggleHomestayVisibility(AdminToggleHomestayVisibility event, Emitter<HomestayState> emit) async {
    emit(const HomestayLoading());
    try {
      final response = await _datasource.toggleVisibility(event.id, event.isVisible);
      if (response.statusCode == 200) {
        add(const TouristLoadAllHomestays());
      } else {
        emit(HomestayError('Failed to update status: ${response.statusCode}'));
      }
    } catch (e) {
      emit(HomestayError('Network error: $e'));
    }
  }
}