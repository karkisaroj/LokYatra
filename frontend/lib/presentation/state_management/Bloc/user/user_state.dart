// lib/presentation/state_management/Bloc/user/user_state.dart

import 'package:lokyatra_frontend/data/models/user.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<User> users;
  UserLoaded(this.users);
}


class UserDeleted extends UserState {
  final int userId;
  final int homestaysDeleted;
  final String message;

  UserDeleted(
      this.userId, {
        this.homestaysDeleted = 0,
        this.message = 'User deleted.',
      });
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}