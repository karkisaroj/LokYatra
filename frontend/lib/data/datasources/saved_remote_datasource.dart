// lib/data/datasources/saved_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:lokyatra_frontend/core/constants.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/SecureStorageService.dart';

class SavedRemoteDatasource {
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

  /// Toggle save/unsave. Returns { saved: bool }
  Future<Response> toggleSaved(int homestayId) async =>
      _dio.post('api/Saved/$homestayId', options: await _authOptions());

  /// Get all saved homestays for the current tourist
  Future<Response> getSaved() async =>
      _dio.get('api/Saved', options: await _authOptions());

  /// Check if a specific homestay is saved
  Future<Response> checkSaved(int homestayId) async =>
      _dio.get('api/Saved/$homestayId/check', options: await _authOptions());
}