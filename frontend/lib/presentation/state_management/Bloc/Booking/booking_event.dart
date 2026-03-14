abstract class BookingEvent {
  const BookingEvent();
}


class LoadMyBookings extends BookingEvent {
  const LoadMyBookings();
}

class CancelMyBooking extends BookingEvent {
  final int bookingId;
  const CancelMyBooking(this.bookingId);
}


class LoadOwnerBookings extends BookingEvent {
  const LoadOwnerBookings();
}

class UpdateBookingStatus extends BookingEvent {
  final int bookingId;
  final String status; // 'Confirmed' | 'Rejected' | 'Completed'
  final String? rejectionReason;
  const UpdateBookingStatus(this.bookingId, this.status, {this.rejectionReason});
}

/// Owner taps "Mark as Paid" on a confirmed booking
class MarkPaymentReceived extends BookingEvent {
  final int bookingId;
  const MarkPaymentReceived(this.bookingId);
}

/// Load owner revenue summary for the earnings card
class LoadOwnerRevenue extends BookingEvent {
  const LoadOwnerRevenue();
}

// Admin

class LoadAllBookings extends BookingEvent {
  const LoadAllBookings();
}