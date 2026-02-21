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
    ),
  );

  Future<Options> _authOptions() async {
    final token = await SecureStorageService.getAccessToken();
    if (token == null) throw Exception('Not authenticated');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // Public: sends token if available so admin sees ALL homestays,
  // tourists/unauthenticated only see visible ones.
  // The backend checks IsInRole("admin") — if token present and role = admin,
  // it skips the isVisible filter.
  Future<Response> getAllHomestays() async {
    final token = await SecureStorageService.getAccessToken();
    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : Options();
    return _dio.get('api/Homestays', options: options);
  }

  // Owner: only owner's own homestays
  Future<Response> getMyHomestays() async {
    return _dio.get('api/Homestays/my-homestays',
        options: await _authOptions());
  }

  // Owner: create homestay
  Future<Response> createHomestay({
    required Map<String, dynamic> fields,
    required List<PlatformFile> files,
  }) async {
    final formData = FormData();
    fields.forEach((key, value) {
      if (value != null) formData.fields.add(MapEntry(key, value.toString()));
    });
    for (final file in files) {
      if (file.path != null) {
        formData.files.add(MapEntry(
          'Images',
          await MultipartFile.fromFile(file.path!, filename: file.name),
        ));
      }
    }
    return _dio.post('api/Homestays',
        data: formData, options: await _authOptions());
  }

  // Owner: update homestay
  Future<Response> updateHomestay({
    required int id,
    required Map<String, dynamic> fields,
    required List<PlatformFile> files,
  }) async {
    final formData = FormData();
    fields.forEach((key, value) {
      if (value != null) formData.fields.add(MapEntry(key, value.toString()));
    });
    for (final file in files) {
      if (file.path != null) {
        formData.files.add(MapEntry(
          'Images',
          await MultipartFile.fromFile(file.path!, filename: file.name),
        ));
      }
    }
    return _dio.put('api/Homestays/$id',
        data: formData, options: await _authOptions());
  }

  // Owner/Admin: toggle visibility
  Future<Response> toggleVisibility(int id, bool isVisible) async {
    return _dio.patch(
      'api/Homestays/$id/toggle-visibility',
      data: {'isVisible': isVisible},
      options: await _authOptions(),
    );
  }

  // Admin: delete homestay
  Future<Response> deleteHomestay(int id) async {
    return _dio.delete('api/Homestays/$id', options: await _authOptions());
  }
}