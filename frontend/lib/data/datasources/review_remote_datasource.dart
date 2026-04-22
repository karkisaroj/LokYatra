import 'package:dio/dio.dart';
import 'package:lokyatra_frontend/core/services/constants.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/secure_storage_service.dart';

class ReviewRemoteDatasource {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: connectTimeout,
    receiveTimeout: receiveTimeout,
    sendTimeout: sendTimeout,
  ));

  Future<Options> _authOptions() async {
    final token = await SecureStorageService.getAccessToken();
    if (token == null) throw Exception('Not authenticated');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }
  Future<Response> getMyReviews() async {
    final token = await SecureStorageService.getAccessToken();
    return _dio.get(
      '/api/Review/my-reviews',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
  Future<Response> getHomestayReviews(int homestayId) async {
    return _dio.get('api/Review/homestay/$homestayId');
  }

  Future<Response> getSiteReviews(int siteId) async {
    return _dio.get('api/Review/site/$siteId');
  }

  Future<Response> getMyBookingReview(int bookingId) async {
    return _dio.get('api/Review/my/booking/$bookingId', options: await _authOptions());
  }

  Future<Response> getMySiteReview(int siteId) async {
    return _dio.get('api/Review/my/site/$siteId', options: await _authOptions());
  }

  Future<Response> createHomestayReview({
    required int bookingId,
    required int homestayId,
    required int rating,
    String? comment,
  }) async {
    return _dio.post(
      'api/Review/homestay',
      data: {'bookingId': bookingId, 'homestayId': homestayId, 'rating': rating, 'comment': comment},
      options: await _authOptions(),
    );
  }

  Future<Response> createSiteReview({
    required int siteId,
    required int rating,
    String? comment,
  }) async {
    return _dio.post(
      'api/Review/site',
      data: {'siteId': siteId, 'rating': rating, 'comment': comment},
      options: await _authOptions(),
    );
  }

  Future<Response> updateReview(int id, {required int rating, String? comment}) async {
    return _dio.put(
      'api/Review/$id',
      data: {'rating': rating, 'comment': comment},
      options: await _authOptions(),
    );
  }

  Future<Response> deleteReview(int id) async {
    return _dio.delete('api/Review/$id', options: await _authOptions());
  }

  Future<Response> getAllReviews({String? type, int? rating}) async {
    final params = <String, dynamic>{};
    if (type != null) params['type'] = type;
    if (rating != null) params['rating'] = rating;
    return _dio.get(
      'api/Review/all',
      queryParameters: params.isEmpty ? null : params,
      options: await _authOptions(),
    );
  }
}
