import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/data/datasources/homestays_remote_datasource.dart';

import 'HomestayEvent.dart';
import 'HomestayState.dart';


class HomestayBloc extends Bloc<HomestayEvent, HomestayState> {
  final HomestaysRemoteDatasource _datasource = HomestaysRemoteDatasource();

  HomestayBloc() : super(HomestayInitial()) {
    on<LoadMyHomestays>(_onLoadMyHomestays);
  }

  Future<void> _onLoadMyHomestays(LoadMyHomestays event, Emitter<HomestayState> emit) async {
    emit(HomestayLoading());
    try {
      final response = await _datasource.getMyHomestays();
      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        emit(HomestaysLoaded(data));
      } else {
        emit(HomestayError('Failed to load homestays: ${response.statusCode}'));
      }
    } catch (error) {
      emit(HomestayError('Network error: $error'));
    }
  }
}