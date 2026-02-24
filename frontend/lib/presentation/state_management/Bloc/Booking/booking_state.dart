abstract class BookingState {
  const BookingState();
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class MyBookingsLoaded extends BookingState {
  final List<Map<String, dynamic>> bookings;
  const MyBookingsLoaded(this.bookings);
}

class OwnerBookingsLoaded extends BookingState {
  final List<Map<String, dynamic>> bookings;
  const OwnerBookingsLoaded(this.bookings);
}

class BookingActionSuccess extends BookingState {
  final String message;
  const BookingActionSuccess(this.message);
}

class BookingError extends BookingState {
  final String message;
  const BookingError(this.message);
}