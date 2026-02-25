// lib/presentation/state_management/Bloc/booking/booking_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/datasources/booking_remote_datasource.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRemoteDatasource _remote = BookingRemoteDatasource();

  // Cache bookings so we can re-emit them when revenue loads
  List<Map<String, dynamic>> _cachedOwnerBookings = [];

  BookingBloc() : super(BookingInitial()) {
    on<LoadMyBookings>(_onLoadMyBookings);
    on<CancelMyBooking>(_onCancelMyBooking);
    on<LoadOwnerBookings>(_onLoadOwnerBookings);
    on<UpdateBookingStatus>(_onUpdateBookingStatus);
    on<MarkPaymentReceived>(_onMarkPaymentReceived);
    on<LoadOwnerRevenue>(_onLoadOwnerRevenue);
    on<LoadAllBookings>(_onLoadAllBookings);
  }

  // ── Tourist ─────────────────────────────────────────────────────────────────

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

  // ── Owner ────────────────────────────────────────────────────────────────────

  Future<void> _onLoadOwnerBookings(
      LoadOwnerBookings event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final resp = await _remote.getOwnerBookings();
      if (resp.statusCode == 200) {
        final raw = resp.data as List<dynamic>;
        _cachedOwnerBookings = raw.cast<Map<String, dynamic>>();
        emit(OwnerBookingsLoaded(_cachedOwnerBookings));
        // Also reload revenue whenever bookings refresh
        add(const LoadOwnerRevenue());
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
        final msg = switch (event.status) {
          'Confirmed' => 'Booking confirmed!',
          'Rejected'  => 'Booking rejected',
          'Completed' => 'Marked as completed',
          _           => 'Booking updated',
        };
        emit(BookingActionSuccess(msg));
        add(const LoadOwnerBookings());
      } else {
        emit(BookingError('Failed to update: ${resp.statusCode}'));
      }
    } catch (e) {
      emit(BookingError('Network error: $e'));
    }
  }

  /// Owner marks a cash payment as received → PaymentStatus becomes Paid
  Future<void> _onMarkPaymentReceived(
      MarkPaymentReceived event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final resp = await _remote.markPaymentReceived(event.bookingId);
      if (resp.statusCode == 200) {
        emit(const BookingActionSuccess('Payment recorded successfully!'));
        add(const LoadOwnerBookings()); // refresh list + revenue
      } else {
        emit(BookingError('Failed to record payment: ${resp.statusCode}'));
      }
    } catch (e) {
      emit(BookingError('Network error: $e'));
    }
  }

  /// Load revenue summary for the owner earnings card
  Future<void> _onLoadOwnerRevenue(
      LoadOwnerRevenue event, Emitter<BookingState> emit) async {
    try {
      final resp = await _remote.getOwnerRevenue();
      if (resp.statusCode == 200) {
        final d = resp.data as Map<String, dynamic>;
        emit(OwnerRevenueLoaded(
          totalRevenue:   (d['totalRevenue']   as num?)?.toDouble() ?? 0,
          cashRevenue:    (d['cashRevenue']    as num?)?.toDouble() ?? 0,
          khaltiRevenue:  (d['khaltiRevenue']  as num?)?.toDouble() ?? 0,
          pendingRevenue: (d['pendingRevenue'] as num?)?.toDouble() ?? 0,
          paidBookings:   (d['paidBookings']   as int?)            ?? 0,
          totalBookings:  (d['totalBookings']  as int?)            ?? 0,
        ));
      }
      // silently ignore revenue errors — bookings are still shown
    } catch (_) {}
  }

  // ── Admin ────────────────────────────────────────────────────────────────────

  Future<void> _onLoadAllBookings(
      LoadAllBookings event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final resp = await _remote.getAllBookings();
      if (resp.statusCode == 200) {
        final raw = resp.data as List<dynamic>;
        emit(AllBookingsLoaded(raw.cast<Map<String, dynamic>>()));
      } else {
        emit(BookingError('Failed to load all bookings: ${resp.statusCode}'));
      }
    } catch (e) {
      emit(BookingError('Network error: $e'));
    }
  }
}