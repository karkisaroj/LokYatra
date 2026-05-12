abstract class UserEvent {}

class FetchUsers extends UserEvent {}

class DeleteUsers extends UserEvent {
  final int userId;
  DeleteUsers(this.userId);
}