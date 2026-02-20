import 'package:dio/dio.dart';
import 'package:lokyatra_frontend/core/constants.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/SecureStorageService.dart';

class UserRemoteDatasource {
  late final Dio _dio;

  UserRemoteDatasource() {
    _dio = Dio(
      BaseOptions(
          baseUrl: apiBaseUrl,
          connectTimeout: connectTimeout,
          receiveTimeout: receiveTimeout,
          contentType: "application/json",
          responseType: ResponseType.json,
          headers: headers
      ),
    );

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<Options> _authOptions() async {
    final token = await SecureStorageService.getAccessToken();

    if (token == null) {
      throw Exception("Access token is null. User not authenticated.");
    }

    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  /// GET api/User/me
  Future<Response> getMe() async {
    return _dio.get(
      me,
      options: await _authOptions(),
    );
  }

  /// GET api/User/getUsers  (admin only)
  Future<Response> getUsers() async {
    return _dio.get(
      getUsersEndpoint,
      options: await _authOptions(),
    );
  }

  /// DELETE api/User/deleteUser/{userId}  (admin only)
  Future<Response> deleteUser(int userId) async {
    return _dio.delete(
      '$deleteUserEndpoint/$userId',
      options: await _authOptions(),
    );
  }

  /// PATCH api/User/update-profile
  Future<Response> updateProfile({
    String? name,
    String? phoneNumber,
    String? imagePath,
    String? imageFileName,
  }) async {
    final token = await SecureStorageService.getAccessToken();

    if (token == null) {
      throw Exception("Access token is null.");
    }

    final formData = FormData();

    if (name != null && name.isNotEmpty) {
      formData.fields.add(MapEntry('Name', name));
    }

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      formData.fields.add(MapEntry('PhoneNumber', phoneNumber));
    }

    if (imagePath != null) {
      formData.files.add(
        MapEntry(
          'ProfileImageFile',
          await MultipartFile.fromFile(
            imagePath,
            filename: imageFileName ?? 'profile.jpg',
          ),
        ),
      );
    }

    return _dio.patch(
      'api/User/update-profile',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );
  }
}