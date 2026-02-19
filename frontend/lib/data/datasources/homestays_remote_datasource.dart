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

  Future<Options> _authOptions() async {
    final token = await SecureStorageService.getAccessToken();
    return Options(headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });
  }

  Future<Response<dynamic>> getMyHomestays() async {
    return _dio.get(
      '$homestaysBasePath/OwnerStay',
      options: await _authOptions(),
    );
  }

  Future<Response<dynamic>> getHomestay(int id) async {
    return _dio.get(
      '$homestaysBasePath/$id',
      options: await _authOptions(),
    );
  }

  Future<Response<dynamic>> createHomestay({
    required Map<String, dynamic> fields,
    required List<PlatformFile> files,
  }) async {
    final formData = FormData();

    fields.forEach((key, value) {
      if (value != null) {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    for (final file in files) {
      if (file.path != null) {
        formData.files.add(MapEntry(
          'files',
          await MultipartFile.fromFile(file.path!, filename: file.name),
        ));
      }
    }

    final token = await SecureStorageService.getAccessToken();
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

  Future<Response<dynamic>> updateHomestay({
    required int id,
    required Map<String, dynamic> fields,
    List<PlatformFile> files = const [],
  }) async {
    final token = await SecureStorageService.getAccessToken();
    final formData = FormData();

    fields.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    for (final file in files) {
      if (file.path != null) {
        formData.files.add(MapEntry(
          'files',
          await MultipartFile.fromFile(
            file.path!,
            filename: file.name ?? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        ));
      }
    }

    return _dio.put(
      '$homestaysBasePath/$id',
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
  }

  Future<Response<dynamic>> toggleVisibility(int id, bool isVisible) async {
    return _dio.patch(
      '$homestaysBasePath/$id/visibility',
      data: {'isVisible': isVisible},
      options: await _authOptions(),
    );
  }

  Future<Response<dynamic>> deleteHomestay(int id) async {
    return _dio.delete(
      '$homestaysBasePath/$id',
      options: await _authOptions(),
    );
  }
}