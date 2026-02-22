// lib/presentation/state_management/Bloc/user/user_event.dart

abstract class UserEvent {}

class FetchUsers extends UserEvent {}

class DeleteUsers extends UserEvent {
  final int userId;
  DeleteUsers(this.userId);
}