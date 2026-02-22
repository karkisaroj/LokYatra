// lib/presentation/state_management/Bloc/user/user_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/data/datasources/user_remote_datasource.dart';
import 'package:lokyatra_frontend/data/models/user.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRemoteDatasource _datasource = UserRemoteDatasource();

  UserBloc() : super(UserInitial()) {
    on<FetchUsers>(_onFetchUsers);
    on<DeleteUsers>(_onDeleteUser);
  }

  Future<void> _onFetchUsers(
      FetchUsers event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final response = await _datasource.getUsers();
      if (response.statusCode == 200) {
        final raw = response.data as List<dynamic>;
        final users = raw.map((j) => User.fromJson(j)).toList();
        emit(UserLoaded(users));
      } else {
        emit(UserError('Failed to load users: ${response.statusCode}'));
      }
    } catch (e) {
      emit(UserError('Network error: $e'));
    }
  }

  Future<void> _onDeleteUser(
      DeleteUsers event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final response = await _datasource.deleteUser(event.userId);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final homestaysDeleted = data['homestaysDeleted'] as int? ?? 0;
        final message = data['message'] as String? ?? 'User deleted.';
        emit(UserDeleted(event.userId,
            homestaysDeleted: homestaysDeleted, message: message));
        add(FetchUsers()); // refresh the list
      } else if (response.statusCode == 400) {
        final data = response.data as Map<String, dynamic>? ?? {};
        final message =
            data['message'] as String? ?? 'Cannot delete this user.';
        emit(UserError(message));
      } else {
        emit(UserError('Delete failed: ${response.statusCode}'));
      }
    } catch (e) {
      emit(UserError('Network error: $e'));
    }
  }
}