import 'package:dio/dio.dart';
import 'package:lokyatra_frontend/core/services/constants.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/SecureStorageService.dart';

class SavedSitesRemoteDatasource {
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

  Future<Response> toggleSaved(int siteId) async =>
      _dio.post('api/SavedSites/$siteId', options: await _authOptions());

  Future<Response> getSaved() async =>
      _dio.get('api/SavedSites', options: await _authOptions());

  Future<Response> checkSaved(int siteId) async =>
      _dio.get('api/SavedSites/$siteId/check', options: await _authOptions());
}
