import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lokyatra_frontend/core/services/constants.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/secure_storage_service.dart';

class SitesRemoteDatasource {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      headers: headers,
      responseType: ResponseType.json,
    ),
  )..interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  Future<Response<dynamic>> getSites({String? q}) {
    return _dio.get(
      sitesBasePath,
      queryParameters: q != null && q.isNotEmpty ? {'q': q} : null,
    );
  }

  Future<Response<dynamic>> getSite(int id) => _dio.get('$sitesBasePath/$id');

  Future<Response<dynamic>> createSite({
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

    for (final f in files) {
      if (f.bytes != null) {
        formData.files.add(MapEntry('files', MultipartFile.fromBytes(f.bytes!, filename: f.name)));
      } else if (f.path != null) {
        formData.files.add(MapEntry('files', await MultipartFile.fromFile(f.path!, filename: f.name)));
      }
    }

    return _dio.post(
      sitesBasePath,
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': null, 
        },
        sendTimeout: uploadSendTimeout,
        receiveTimeout: uploadReceiveTimeout,
      ),
    );
  }

  Future<Response<dynamic>> updateSite({
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

    for (final f in files) {
      if (f.bytes != null) {
        formData.files.add(MapEntry('files', MultipartFile.fromBytes(f.bytes!, filename: f.name)));
      } else if (f.path != null) {
        formData.files.add(MapEntry('files', await MultipartFile.fromFile(f.path!, filename: f.name)));
      }
    }

    return _dio.put(
      '$sitesBasePath/$id',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': null, // Let Dio set the correct multipart boundary
        },
        sendTimeout: uploadSendTimeout,
        receiveTimeout: uploadReceiveTimeout,
      ),
    );
  }

  Future<Response<dynamic>> deleteSite(int id) async {
    final token = await SecureStorageService.getAccessToken();
    return _dio.delete(
      '$sitesBasePath/$id',
      options: Options(headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'}),
    );
  }
}
