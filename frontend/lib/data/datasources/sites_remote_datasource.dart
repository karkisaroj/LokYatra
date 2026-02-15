import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lokyatra_frontend/core/constants.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/SecureStorageService.dart';

class SitesRemoteDatasource {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 20), // GETs ok
      sendTimeout: Duration(seconds: 20),
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

    // Longer timeouts for uploads
    return _dio.post(
      sitesBasePath,
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
        sendTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 120),
      ),
    );
  }
}