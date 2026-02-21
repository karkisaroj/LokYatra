import 'package:dio/dio.dart';
import 'package:lokyatra_frontend/core/constants.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/SecureStorageService.dart';

class BookingRemoteDatasource {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      responseType: ResponseType.json,
    ),
  )..interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  Future<Options> _authOptions() async {
    final token = await SecureStorageService.getAccessToken();
    if (token == null) throw Exception('Not authenticated');
    return Options(headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    });
  }

  Future<Response> createBooking({
    required int homestayId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int rooms,
    required int guests,
    int pointsToRedeem = 0,
    String paymentMethod = 'PayAtArrival',
    String? specialRequests,
  }) async {
    return _dio.post(
      'api/Booking',
      data: {
        'homestayId':      homestayId,
        'checkIn':         _fmtDate(checkIn),
        'checkOut':        _fmtDate(checkOut),
        'rooms':           rooms,
        'guests':          guests,
        'pointsToRedeem':  pointsToRedeem,
        'paymentMethod':   paymentMethod,
        'specialRequests': specialRequests ?? '',
      },
      options: await _authOptions(),
    );
  }

  Future<Response> getMyBookings() async =>
      _dio.get('api/Booking/my-bookings', options: await _authOptions());

  Future<Response> cancelBooking(int id) async =>
      _dio.patch('api/Booking/$id/cancel', options: await _authOptions());

  Future<Response> getOwnerBookings() async =>
      _dio.get('api/Booking/owner-bookings', options: await _authOptions());

  Future<Response> updateBookingStatus(
      int id, String status, {String? rejectionReason}) async =>
      _dio.patch(
        'api/Booking/$id/status',
        data: {
          'status': status,
          'rejectionReason': rejectionReason,
        },
        options: await _authOptions(),
      );

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}