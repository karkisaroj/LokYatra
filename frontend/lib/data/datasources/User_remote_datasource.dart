import 'package:dio/dio.dart';
import 'package:lokyatra_frontend/core/services/constants.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/SecureStorageService.dart';

class UserRemoteDatasource {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      responseType: ResponseType.json,
      validateStatus: (s) => s != null && s < 600,
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

  Future<Response> getCurrentUser() async =>
      _dio.get('api/User/current-user', options: await _authOptions());

  Future<Response> getUsers() async =>
      _dio.get(getUsersEndpoint, options: await _authOptions());

  Future<Response> deleteUser(int userId) async =>
      _dio.delete('api/User/deleteUser/$userId', options: await _authOptions());

  Future<Response> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async =>
      _dio.post('api/User/change-password',
          data: {
            'currentPassword': currentPassword,
            'newPassword':     newPassword,
          },
          options: await _authOptions());

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
    if (phoneNumber != null ) {
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