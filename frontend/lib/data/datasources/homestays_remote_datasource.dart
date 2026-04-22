import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:lokyatra_frontend/core/services/constants.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/secure_storage_service.dart';

class HomestaysRemoteDatasource {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
    ),
  );

  final Dio uploadDio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: uploadReceiveTimeout,
      sendTimeout: uploadSendTimeout,
    ),
  );

  Future<Options> authOptions() async {
    final token = await SecureStorageService.getAccessToken();
    if (token == null) throw Exception('Not authenticated');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<MultipartFile> toMultipart(PlatformFile file) async {
    if (kIsWeb) {
      return MultipartFile.fromBytes(file.bytes!, filename: file.name);
    } else {
      return await MultipartFile.fromFile(file.path!, filename: file.name);
    }
  }

  Future<Response> getAllHomestays() async {
    final token = await SecureStorageService.getAccessToken();
    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : Options();
    return dio.get('api/Homestays', options: options);
  }

  Future<Response> getMyHomestays() async {
    return dio.get('api/Homestays/my-homestays', options: await authOptions());
  }

  Future<Response> createHomestay({
    required Map<String, dynamic> fields,
    required List<PlatformFile> files,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final token = await SecureStorageService.getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final formData = FormData();

    fields.forEach((key, value) {
      if (value != null) formData.fields.add(MapEntry(key, value.toString()));
    });

    for (final file in files) {
      formData.files.add(MapEntry('Images', await toMultipart(file)));
    }

    return uploadDio.post(
      'api/Homestays',
      data: formData,
      options: Options(
        contentType: null,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
      onSendProgress: (sent, total) {
        onSendProgress?.call(sent, total);
        if (total > 0) {
          (sent / total * 100).toStringAsFixed(0);
        }
      },
    );
  }

  Future<Response> updateHomestay({
    required int id,
    required Map<String, dynamic> fields,
    required List<PlatformFile> files,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final token = await SecureStorageService.getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final formData = FormData();

    fields.forEach((key, value) {
      if (value != null) formData.fields.add(MapEntry(key, value.toString()));
    });

    for (final file in files) {
      formData.files.add(MapEntry('Images', await toMultipart(file)));
    }

    return uploadDio.put(
      'api/Homestays/$id',
      data: formData,
      options: Options(
        contentType: null,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
      onSendProgress: (sent, total) {
        onSendProgress?.call(sent, total);
        if (total > 0) {
          (sent / total * 100).toStringAsFixed(0);
        }
      },
    );
  }

  Future<Response> toggleVisibility(int id, bool isVisible) async {
    return dio.patch(
      'api/Homestays/$id/toggle-visibility',
      data: {'isVisible': isVisible},
      options: await authOptions(),
    );
  }

  Future<Response> deleteHomestay(int id) async {
    return dio.delete('api/Homestays/$id', options: await authOptions());
  }
}
