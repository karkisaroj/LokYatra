import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lokyatra_frontend/core/services/constants.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/SecureStorageService.dart';

class HomestaysRemoteDatasource {
  // Standard Dio for normal GET/PATCH/DELETE calls
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
    ),
  );

  // Separate Dio instance for multipart uploads — no LogInterceptor
  // (logging base64 image bytes freezes the console and adds huge overhead)
  // and much longer timeouts since Cloudinary upload can take 2-3 min on slow WiFi
  final Dio _uploadDio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: uploadReceiveTimeout,
      sendTimeout: uploadSendTimeout,
    ),
  );

  Future<Options> _authOptions() async {
    final token = await SecureStorageService.getAccessToken();
    if (token == null) throw Exception('Not authenticated');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // ── Public: used by both tourists (no token) and admin (with token) ──────────
  Future<Response> getAllHomestays() async {
    final token = await SecureStorageService.getAccessToken();
    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : Options();
    return _dio.get('api/Homestays', options: options);
  }

  // ── Owner: only own homestays ────────────────────────────────────────────────
  Future<Response> getMyHomestays() async {
    return _dio.get('api/Homestays/my-homestays',
        options: await _authOptions());
  }

  // ── Owner: create ────────────────────────────────────────────────────────────
  Future<Response> createHomestay({
    required Map<String, dynamic> fields,
    required List<PlatformFile> files,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final token = await SecureStorageService.getAccessToken();
    if (token == null) throw Exception('Not authenticated');

    final formData = FormData();

    // Add all text fields — required fields are always present,
    // optional ones may be empty strings (backend ignores empty optionals)
    fields.forEach((key, value) {
      if (value != null) {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    // Add image files
    for (final file in files) {
      if (file.path != null) {
        formData.files.add(MapEntry(
          'Images',
          await MultipartFile.fromFile(file.path!, filename: file.name),
        ));
      } else if (file.bytes != null) {
        // Web — FilePicker returns bytes instead of path
        formData.files.add(MapEntry(
          'Images',
          MultipartFile.fromBytes(file.bytes!, filename: file.name),
        ));
      }
    }

    return _uploadDio.post(
      'api/Homestays',
      data: formData,
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        // Don't set Content-Type manually — Dio sets it with boundary automatically
      }),
      // Show real upload progress in the log
      onSendProgress: (sent, total) {
        onSendProgress?.call(sent, total);
        if (total > 0) {
          final pct = (sent / total * 100).toStringAsFixed(0);
          // ignore: avoid_print
          print('[Upload] $pct% ($sent/$total bytes)');
        }
      },
    );
  }

  // ── Owner: update ────────────────────────────────────────────────────────────
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
      if (value != null) {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    for (final file in files) {
      if (file.path != null) {
        formData.files.add(MapEntry(
          'Images',
          await MultipartFile.fromFile(file.path!, filename: file.name),
        ));
      } else if (file.bytes != null) {
        formData.files.add(MapEntry(
          'Images',
          MultipartFile.fromBytes(file.bytes!, filename: file.name),
        ));
      }
    }

    return _uploadDio.put(
      'api/Homestays/$id',
      data: formData,
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      }),
      onSendProgress: (sent, total) {
        onSendProgress?.call(sent, total);
        if (total > 0) {
          final pct = (sent / total * 100).toStringAsFixed(0);
          // ignore: avoid_print
          print('[Upload] $pct% ($sent/$total bytes)');
        }
      },
    );
  }

  // ── Owner/Admin: toggle visibility ───────────────────────────────────────────
  Future<Response> toggleVisibility(int id, bool isVisible) async {
    return _dio.patch(
      'api/Homestays/$id/toggle-visibility',
      data: {'isVisible': isVisible},
      options: await _authOptions(),
    );
  }

  // ── Admin: delete ────────────────────────────────────────────────────────────
  Future<Response> deleteHomestay(int id) async {
    return _dio.delete('api/Homestays/$id', options: await _authOptions());
  }
}
