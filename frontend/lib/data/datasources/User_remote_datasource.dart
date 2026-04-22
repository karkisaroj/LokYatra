import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:lokyatra_frontend/core/services/constants.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/secure_storage_service.dart';

import '../../core/services/sqlite_service.dart';

class UserRemoteDatasource {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      responseType: ResponseType.json,
      validateStatus: (s) => s != null && s < 600,
    ),
  );

  Future<Options> authOptions() async {
    final token = await SecureStorageService.getAccessToken();
    if (token == null) throw Exception('Not authenticated — please log in again.');
    return Options(headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });
  }

  Future<void> refreshCurrentUser() async {
    final token = await SecureStorageService.getAccessToken();
    final res = await dio.get('api/User/current-user',
        options: Options(headers: {'Authorization': 'Bearer $token'}));
    if (res.statusCode == 200) {
      final d = res.data as Map<String, dynamic>;
      await SqliteService().put('user_image', d['profileImage'] as String? ?? '');
      await SqliteService().put('user_name',  d['name'] as String? ?? '');
    }
  }
  Future<Response> getCurrentUser() async =>
      dio.get('api/User/current-user', options: await authOptions());

  Future<Response> getUsers() async =>
      dio.get(getUsersEndpoint, options: await authOptions());

  Future<Response> deleteUser(int userId) async =>
      dio.delete('api/User/deleteUser/$userId', options: await authOptions());

  Future<Response> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async =>
      dio.post('api/User/change-password',
          data: {
            'currentPassword': currentPassword,
            'newPassword': newPassword,
          },
          options: await authOptions());

  Future<MultipartFile> toMultipart(PlatformFile file) async {
    if (kIsWeb) {
      return MultipartFile.fromBytes(file.bytes!, filename: file.name);
    }
    return MultipartFile.fromFile(file.path!, filename: file.name);
  }

  Future<Response> updateProfile({
    String? name,
    String? phoneNumber,
    PlatformFile? imageFile,
  }) async {
    final token = await SecureStorageService.getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final formData = FormData();

    if (name != null && name.isNotEmpty) {
      formData.fields.add(MapEntry('Name', name));
    }
    if (phoneNumber != null) {
      formData.fields.add(MapEntry('PhoneNumber', phoneNumber));
    }
    if (imageFile != null) {
      formData.files.add(MapEntry('ProfileImageFile', await toMultipart(imageFile)));
    }

    return dio.patch(
      'api/User/update-profile',
      data: formData,
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': null,
      }),
    );
  }
}
