import 'package:lokyatra_frontend/data/models/user.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<User> users;
  UserLoaded(this.users);
}

class UserDeleted extends UserState {
  final String message;
  final int    homestaysDeleted;
  UserDeleted({required this.message, required this.homestaysDeleted});
}

class UserError extends UserState {
  final String message;
  UserError(this.message);
}