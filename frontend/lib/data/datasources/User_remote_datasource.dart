import 'package:dio/dio.dart';
import 'package:lokyatra_frontend/core/constants.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/SecureStorageService.dart';

class UserRemoteDatasource {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,   // has trailing slash — correct
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
    });
  }

  Future<Response> getMe() async =>
      _dio.get('api/User/me', options: await _authOptions());

  Future<Response> getUsers() async =>
      _dio.get(getUsersEndpoint, options: await _authOptions());

  Future<Response> deleteUser(int userId) async =>
      _dio.delete('$deleteUserEndpoint/$userId', options: await _authOptions());

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