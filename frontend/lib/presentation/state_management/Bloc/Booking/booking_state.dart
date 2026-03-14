abstract class BookingState {
  const BookingState();
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

//Tourist

class MyBookingsLoaded extends BookingState {
  final List<Map<String, dynamic>> bookings;
  const MyBookingsLoaded(this.bookings);
}

// Owner

class OwnerBookingsLoaded extends BookingState {
  final List<Map<String, dynamic>> bookings;
  /// Revenue summary — null until LoadOwnerRevenue succeeds
  final Map<String, dynamic>? revenue;
  const OwnerBookingsLoaded(this.bookings, {this.revenue});
}

/// Emitted after LoadOwnerRevenue completes (used alongside OwnerBookingsLoaded)
class OwnerRevenueLoaded extends BookingState {
  final double totalRevenue;
  final double cashRevenue;
  final double khaltiRevenue;
  final double pendingRevenue;
  final int paidBookings;
  final int totalBookings;

  const OwnerRevenueLoaded({
    required this.totalRevenue,
    required this.cashRevenue,
    required this.khaltiRevenue,
    required this.pendingRevenue,
    required this.paidBookings,
    required this.totalBookings,
  });
}

// Admin

class AllBookingsLoaded extends BookingState {
  final List<Map<String, dynamic>> bookings;
  const AllBookingsLoaded(this.bookings);
}

//Shared

class BookingActionSuccess extends BookingState {
  final String message;
  const BookingActionSuccess(this.message);
}

class BookingError extends BookingState {
  final String message;
  const BookingError(this.message);
}