import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lokyatra_frontend/core/constants.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/SecureStorageService.dart';

class HomestaysRemoteDatasource {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      headers: headers,
      responseType: ResponseType.json,
    ),
  )..interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

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
      if (file.path != null) {
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(
              file.path!,
              filename: file.name,
            ),
          ),
        );
      }
    }

    return _dio.post(
      homestaysBasePath,
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'multipart/form-data',
        },
        sendTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
      ),
    );
  }

  Future<Response> updateHomestay({
    required int id,
    required Map<String, dynamic> fields,
    List<PlatformFile> files = const [],
  }) async {
    final token = await SecureStorageService.getAccessToken();

    // Use the constant like all your other methods
    final path = '$homestaysBasePath/$id';

    // Debug print – very useful right now
    final fullUrl = '${_dio.options.baseUrl}$path';
    print('Attempting PUT to: $fullUrl');

    final formData = FormData();

    // Text fields – PascalCase to match C# DTO
    fields.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    // Images – using 'images' key (change to 'files' if backend expects that)
    for (final file in files) {
      if (file.path != null) {
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(
              file.path!,
              filename: file.name ?? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ),
        );
      }
    }

    try {
      final response = await _dio.put(
        path,                           // ← important: use path variable here
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          sendTimeout: const Duration(minutes: 3),
          receiveTimeout: const Duration(minutes: 3),
        ),
      );

      print('Update success - status: ${response.statusCode}');
      return response;
    } on DioException catch (e) {
      print('Update failed: ${e.message}');
      if (e.response != null) {
        print('Status: ${e.response?.statusCode}');
        print('Response body: ${e.response?.data}');
        print('Full response headers: ${e.response?.headers}');
      }
      rethrow;
    }
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

