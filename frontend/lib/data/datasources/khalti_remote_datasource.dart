import 'package:dio/dio.dart';
import 'package:lokyatra_frontend/core/services/constants.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/secure_storage_service.dart';

class KhaltiRemoteDatasource {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: connectTimeout,
    receiveTimeout: receiveTimeout,
    responseType: ResponseType.json,
    validateStatus: (status) => status != null && status < 600,
  ));

  Future<Options> _authOptions() async {
    final token = await SecureStorageService.getAccessToken();
    if (token == null) throw Exception('Not authenticated');
    return Options(
      contentType: 'application/json',
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  Future<Response> initiatePayment(int bookingId) async =>
      _dio.post(
        'api/Khalti/initiate/$bookingId',
        options: await _authOptions(),
      );

  Future<Response> verifyPayment(String pidx) async =>
      _dio.post(
        'api/Khalti/verify',
        data: {'pidx': pidx},
        options: await _authOptions(),
      );
}
