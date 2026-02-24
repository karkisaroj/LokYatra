// lib/data/datasources/user_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:lokyatra_frontend/core/constants.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/SecureStorageService.dart';

class UserRemoteDatasource {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      responseType: ResponseType.json,
    ),
  );

  Future<Options> _authOptions() async {
    final token = await SecureStorageService.getAccessToken();
    if (token == null) throw Exception('Not authenticated — please log in again.');
    return Options(headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });
  }

  /// GET api/User/current-user
  Future<Response> getCurrentUser() async =>
      _dio.get('api/User/current-user', options: await _authOptions());

  /// GET api/User/getUsers  (admin only)
  Future<Response> getUsers() async =>
      _dio.get(getUsersEndpoint, options: await _authOptions());

  /// DELETE api/User/deleteUser/{userId}  (admin only)
  /// Response body: { message, homestaysDeleted }
  Future<Response> deleteUser(int userId) async =>
      _dio.delete('api/User/deleteUser/$userId',
          options: await _authOptions());

  /// PATCH api/User/update-profile
  Future<Response> updateProfile({
    String? name,
    String? phoneNumber,
    String? imagePath,
    String? imageFileName,
  }) async {
    final token = await SecureStorageService.getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final formData = FormData();
    if (name != null && name.isNotEmpty) {
      formData.fields.add(MapEntry('Name', name));
    }
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      formData.fields.add(MapEntry('PhoneNumber', phoneNumber));
    }
    if (imagePath != null) {
      formData.files.add(MapEntry(
        'ProfileImageFile',
        await MultipartFile.fromFile(imagePath,
            filename: imageFileName ?? 'profile.jpg'),
      ));
    }

    return _dio.patch(
      'api/User/update-profile',
      data: formData,
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      }),
    );
  }
}