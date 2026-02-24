import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/datasources/booking_remote_datasource.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRemoteDatasource _remote = BookingRemoteDatasource();

  BookingBloc() : super(BookingInitial()) {
    on<LoadMyBookings>(_onLoadMyBookings);
    on<CancelMyBooking>(_onCancelMyBooking);
    on<LoadOwnerBookings>(_onLoadOwnerBookings);
    on<UpdateBookingStatus>(_onUpdateBookingStatus);
  }

  Future<void> _onLoadMyBookings(
      LoadMyBookings event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final resp = await _remote.getMyBookings();
      if (resp.statusCode == 200) {
        final raw = resp.data as List<dynamic>;
        emit(MyBookingsLoaded(raw.cast<Map<String, dynamic>>()));
      } else {
        emit(BookingError('Failed to load bookings: ${resp.statusCode}'));
      }
    } catch (e) {
      emit(BookingError('Network error: $e'));
    }
  }

  Future<void> _onCancelMyBooking(
      CancelMyBooking event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final resp = await _remote.cancelBooking(event.bookingId);
      if (resp.statusCode == 200) {
        emit(const BookingActionSuccess('Booking cancelled'));
        add(const LoadMyBookings());
      } else {
        emit(BookingError('Failed to cancel: ${resp.statusCode}'));
      }
    } catch (e) {
      emit(BookingError('Network error: $e'));
    }
  }

  Future<void> _onLoadOwnerBookings(
      LoadOwnerBookings event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final resp = await _remote.getOwnerBookings();
      if (resp.statusCode == 200) {
        final raw = resp.data as List<dynamic>;
        emit(OwnerBookingsLoaded(raw.cast<Map<String, dynamic>>()));
      } else {
        emit(BookingError('Failed to load: ${resp.statusCode}'));
      }
    } catch (e) {
      emit(BookingError('Network error: $e'));
    }
  }

  Future<void> _onUpdateBookingStatus(
      UpdateBookingStatus event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final resp = await _remote.updateBookingStatus(
        event.bookingId,
        event.status,
        rejectionReason: event.rejectionReason,
      );
      if (resp.statusCode == 200) {
        final msg = event.status == 'Confirmed'
            ? 'Booking confirmed!'
            : event.status == 'Rejected'
            ? 'Booking rejected'
            : 'Booking updated';
        emit(BookingActionSuccess(msg));
        add(const LoadOwnerBookings());
      } else {
        emit(BookingError('Failed to update: ${resp.statusCode}'));
      }
    } catch (e) {
      emit(BookingError('Network error: $e'));
    }
  }
}