abstract class HomestayState {}

class HomestayInitial extends HomestayState {}

class HomestayLoading extends HomestayState {}

class HomestaysLoaded extends HomestayState {
  final List<dynamic> homestays;
  HomestaysLoaded(this.homestays);
}

class HomestayError extends HomestayState {
  final String message;
  HomestayError(this.message);
}