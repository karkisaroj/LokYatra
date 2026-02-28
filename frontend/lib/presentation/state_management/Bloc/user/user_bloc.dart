import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/data/datasources/user_remote_datasource.dart';
import 'package:lokyatra_frontend/data/models/user.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<FetchUsers>(_onFetch);
    on<DeleteUsers>(_onDelete);
  }

  Future<void> _onFetch(FetchUsers event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final res = await UserRemoteDatasource().getUsers();
      if (res.statusCode == 200) {
        final list = (res.data as List)
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .toList();
        emit(UserLoaded(list));
      } else {
        final msg = (res.data as Map?)?['message'] ?? 'Failed to load users';
        emit(UserError(msg.toString()));
      }
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message']
          ?? e.message
          ?? 'Network error';
      emit(UserError(msg.toString()));
    } catch (e) {
      emit(UserError('Unexpected error: $e'));
    }
  }

  Future<void> _onDelete(DeleteUsers event, Emitter<UserState> emit) async {
    final current = state is UserLoaded
        ? List<User>.from((state as UserLoaded).users)
        : <User>[];

    try {
      final res = await UserRemoteDatasource().deleteUser(event.userId);

      if (res.statusCode == 200) {
        final msg            = (res.data as Map?)?['message']          as String? ?? 'User deleted';
        final homestaysCount = (res.data as Map?)?['homestaysDeleted'] as int?    ?? 0;
        final updated        = current.where((u) => u.id != event.userId).toList();

        emit(UserDeleted(message: msg, homestaysDeleted: homestaysCount));
        emit(UserLoaded(updated));
      } else {
        // 400 / 403 — show the backend's block reason
        final msg = (res.data as Map?)?['message'] ?? 'Could not delete user';
        emit(UserError(msg.toString()));
        emit(UserLoaded(current)); // restore list
      }
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message']
          ?? e.message
          ?? 'Network error';
      emit(UserError(msg.toString()));
      emit(UserLoaded(current));
    } catch (e) {
      emit(UserError('Unexpected error: $e'));
      emit(UserLoaded(current));
    }
  }
}