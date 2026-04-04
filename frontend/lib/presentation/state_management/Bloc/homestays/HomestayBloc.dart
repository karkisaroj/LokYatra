import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/core/services/sqlite_service.dart';
import 'package:lokyatra_frontend/data/datasources/homestays_remote_datasource.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';
import 'HomestayEvent.dart';
import 'HomestayState.dart';

class HomestayBloc extends Bloc<HomestayEvent, HomestayState> {
  final HomestaysRemoteDatasource _datasource = HomestaysRemoteDatasource();
  final SqliteService _sqlite     = SqliteService();

  HomestayBloc() : super(const HomestayInitial()) {
    on<OwnerLoadMyHomestays>(_onOwnerLoadMyHomestays);
    on<OwnerUpdateHomestay>(_onOwnerUpdateHomestay);
    on<TouristLoadAllHomestays>(_onTouristLoadAllHomestays);
    on<TouristLoadHomestaysNearSite>(_onTouristLoadHomestaysNearSite);
    on<ResetHomestayState>(_onResetHomestayState);
    on<AdminDeleteHomestay>(_onAdminDeleteHomestay);
    on<AdminToggleHomestayVisibility>(_onAdminToggleHomestayVisibility);
  }


  Future<void> _onTouristLoadAllHomestays(
      TouristLoadAllHomestays event, Emitter<HomestayState> emit) async {
    final cached = await _sqlite.getCachedHomestays();
    if (cached.isNotEmpty) {
      emit(TouristAllHomestaysLoaded(_parseHomestays(cached)));
    }

    final isOnline = await _sqlite.isOnline();
    if (!isOnline) {
      if (cached.isEmpty) {
        emit(const HomestayError('No internet and no cached homestays.'));
      }
      return;
    }

    try {
      final resp = await _datasource.getAllHomestays();
      if (resp.statusCode == 200) {
        final raw = resp.data as List<dynamic>;
        await _sqlite.cacheHomestays(raw);
        emit(TouristAllHomestaysLoaded(_parseHomestays(raw)));
      } else if (cached.isEmpty) {
        emit(HomestayError('Failed: ${resp.statusCode}'));
      }
    } catch (e) {
      if (cached.isEmpty) {
        emit(const HomestayError('Network error. Check your connection.'));
      }
    }
  }

  Future<void> _onTouristLoadHomestaysNearSite(
      TouristLoadHomestaysNearSite event, Emitter<HomestayState> emit) async {
    final cached = await _sqlite.getCachedHomestays();
    
    Future<List<Homestay>> filterNearby(List<dynamic> raw) async {
      return _parseHomestays(raw).where((h) {
        if (!h.isVisible) return false;
        final siteName = h.nearCulturalSite?.name.toLowerCase() ?? '';
        return siteName.contains(event.siteName.toLowerCase());
      }).toList();
    }

    if (cached.isNotEmpty) {
      emit(TouristNearbyHomestaysLoaded(await filterNearby(cached), event.siteName));
    }

    final isOnline = await _sqlite.isOnline();
    if (!isOnline) return;

    try {
      final resp = await _datasource.getAllHomestays();
      if (resp.statusCode == 200) {
        final raw = resp.data as List<dynamic>;
        await _sqlite.cacheHomestays(raw);
        emit(TouristNearbyHomestaysLoaded(await filterNearby(raw), event.siteName));
      }
    } catch (_) {}
  }


  Future<void> _onOwnerLoadMyHomestays(
      OwnerLoadMyHomestays event, Emitter<HomestayState> emit) async {
    emit(const HomestayLoading());
    try {
      final resp = await _datasource.getMyHomestays();
      if (resp.statusCode == 200) {
        final homestays = _parseHomestays(resp.data as List<dynamic>);
        emit(OwnerHomestaysLoaded(homestays));
      } else {
        emit(HomestayError('Failed: ${resp.statusCode}'));
      }
    } catch (e) {
      emit(HomestayError('Network error: $e'));
    }
  }

  Future<void> _onOwnerUpdateHomestay(
      OwnerUpdateHomestay event, Emitter<HomestayState> emit) async {
    emit(const HomestayLoading());
    try {
      final resp = await _datasource.updateHomestay(
          id: event.id, fields: event.fields, files: event.files);
      if (resp.statusCode == 200 || resp.statusCode == 204) {
        add(const OwnerLoadMyHomestays());
      } else {
        emit(HomestayError('Failed to update: ${resp.statusCode}'));
      }
    } catch (e) {
      emit(HomestayError('Network error: $e'));
    }
  }


  Future<void> _onAdminDeleteHomestay(
      AdminDeleteHomestay event, Emitter<HomestayState> emit) async {
    emit(const HomestayLoading());
    try {
      final resp = await _datasource.deleteHomestay(event.id);
      if (resp.statusCode == 200 || resp.statusCode == 204) {
        await Future.delayed(const Duration(milliseconds: 500));
        // Invalidate cache so next load is fresh
        await _sqlite.cacheHomestays([]);
        add(const TouristLoadAllHomestays());
      } else {
        emit(HomestayError('Failed to delete: ${resp.statusCode}'));
      }
    } catch (e) {
      emit(HomestayError('Network error: $e'));
    }
  }

  Future<void> _onAdminToggleHomestayVisibility(
      AdminToggleHomestayVisibility event, Emitter<HomestayState> emit) async {
    emit(const HomestayLoading());
    try {
      final resp = await _datasource.toggleVisibility(event.id, event.isVisible);
      if (resp.statusCode == 200) {
        await _sqlite.cacheHomestays([]);
        add(const TouristLoadAllHomestays());
      } else {
        emit(HomestayError('Failed to update status: ${resp.statusCode}'));
      }
    } catch (e) {
      emit(HomestayError('Network error: $e'));
    }
  }

  Future<void> _onResetHomestayState(
      ResetHomestayState event, Emitter<HomestayState> emit) async {
    emit(const HomestayInitial());
  }


  List<Homestay> _parseHomestays(List<dynamic> raw) =>
      raw.map((j) => Homestay.fromJson(j as Map<String, dynamic>)).toList();
}