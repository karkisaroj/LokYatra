import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lokyatra_frontend/core/constants.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/SecureStorageService.dart';

class HomestaysRemoteDatasource {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: headers,
      responseType: ResponseType.json,
    ),
  )..interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  // Get all homestays for the logged-in owner
  Future<Response<dynamic>> getMyHomestays() async {
    final token = await SecureStorageService.getAccessToken();
    return _dio.get(
      '$homestaysBasePath/OwnerStay',
      options: Options(headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'}),
    );
  }

  // Get single homestay
  Future<Response<dynamic>> getHomestay(int id) async {
    final token = await SecureStorageService.getAccessToken();
    return _dio.get(
      '$homestaysBasePath/$id',
      options: Options(headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'}),
    );
  }

  // Create a new homestay
  Future<Response<dynamic>> createHomestay({
    required Map<String, dynamic> fields,
    required List<PlatformFile> files,
  }) async {
    final token = await SecureStorageService.getAccessToken();
    final formData = FormData();

    fields.forEach((key, value) {
      if (value != null) {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    for (final file in files) {
      if (file.bytes != null) {
        formData.files.add(MapEntry('files', MultipartFile.fromBytes(file.bytes!, filename: file.name)));
      } else if (file.path != null) {
        formData.files.add(MapEntry('files', await MultipartFile.fromFile(file.path!, filename: file.name)));
      }
    }

    return _dio.post(
      homestaysBasePath,
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
        sendTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 120),
      ),
    );
  }

  // Update a homestay
  Future<Response<dynamic>> updateHomestay({
    required int id,
    required Map<String, dynamic> fields,
    required List<PlatformFile> files,
  }) async {
    final token = await SecureStorageService.getAccessToken();
    final formData = FormData();

    fields.forEach((key, value) {
      if (value != null) {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    for (final file in files) {
      if (file.bytes != null) {
        formData.files.add(MapEntry('files', MultipartFile.fromBytes(file.bytes!, filename: file.name)));
      } else if (file.path != null) {
        formData.files.add(MapEntry('files', await MultipartFile.fromFile(file.path!, filename: file.name)));
      }
    }

    return _dio.put(
      '$homestaysBasePath/$id',
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
        sendTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 120),
      ),
    );
  }

  // Toggle visibility (active/paused)
  Future<Response<dynamic>> toggleVisibility(int id, bool isVisible) async {
    final token = await SecureStorageService.getAccessToken();
    return _dio.patch(
      '$homestaysBasePath/$id/visibility',
      data: {'isVisible': isVisible},
      options: Options(headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'}),
    );
  }

  // Delete a homestay
  Future<Response<dynamic>> deleteHomestay(int id) async {
    final token = await SecureStorageService.getAccessToken();
    return _dio.delete(
      '$homestaysBasePath/$id',
      options: Options(headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'}),
    );
  }

}

