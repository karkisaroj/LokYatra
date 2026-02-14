
import 'package:equatable/equatable.dart';
import 'package:lokyatra_frontend/data/models/user.dart';

abstract class UserState extends Equatable{
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState{}

class UserLoading extends UserState{}

class UserLoaded extends UserState{
  final List<User> users;
  UserLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class UserError extends UserState{
  final String message;
  UserError(this.message);
  @override
  List<Object?> get props => [message];
}

class UserDeleted extends UserState{
  final int userId;
  UserDeleted(this.userId);

  @override
  List<Object?> get props => [userId];

}