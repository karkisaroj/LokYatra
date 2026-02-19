import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/data/datasources/homestays_remote_datasource.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';
import 'HomestayEvent.dart';
import 'HomestayState.dart';

class HomestayBloc extends Bloc<HomestayEvent, HomestayState> {
  final HomestaysRemoteDatasource _datasource = HomestaysRemoteDatasource();

  HomestayBloc() : super(const HomestayInitial()) {
    on<LoadMyHomestays>(_onLoadMyHomestays);
    on<UpdateHomestay>(_onUpdateHomestay);
  }

  Future<void> _onLoadMyHomestays(
      LoadMyHomestays event,
      Emitter<HomestayState> emit,
      ) async {
    emit(const HomestayLoading());

    try {
      final response = await _datasource.getMyHomestays();

      if (response.statusCode == 200) {
        final List data = response.data;
        final homestays = data.map((json) => Homestay.fromJson(json)).toList();
        emit(HomestaysLoaded(homestays));
      } else {
        emit(HomestayError('Failed to load: ${response.statusCode}'));
      }
    } catch (e) {
      emit(HomestayError('Network error: $e'));
    }
  }

  Future<void> _onUpdateHomestay(
      UpdateHomestay event,
      Emitter<HomestayState> emit,
      ) async {
    emit(const HomestayLoading());

    try {
      final response = await _datasource.updateHomestay(
        id: event.id,
        fields: event.fields,
        files: event.files,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        add(const LoadMyHomestays()); // Reload list after update
      } else {
        emit(HomestayError('Failed to update: ${response.statusCode}'));
      }
    } catch (e) {
      emit(HomestayError('Network error: $e'));
    }
  }
}