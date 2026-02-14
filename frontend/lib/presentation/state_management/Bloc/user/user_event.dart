import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class FetchUsers extends UserEvent {}

class DeleteUsers extends UserEvent{
  final int userId;

  const DeleteUsers(this.userId);

  @override
  List<Object> get props => [userId];
}
