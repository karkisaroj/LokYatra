
import 'package:dio/dio.dart';
import 'package:lokyatra_frontend/core/constants.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/SecureStorageService.dart';

class QuizRemoteDatasource {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: connectTimeout,
    receiveTimeout: receiveTimeout,
    responseType: ResponseType.json,
    validateStatus: (s) => s != null && s < 600,
  ));

  Future<Options> _auth() async {
    final token = await SecureStorageService.getAccessToken();
    if (token == null) throw Exception('Not authenticated');
    return Options(headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    });
  }

  // Admin
  Future<Response> adminGetQuestions() async =>
      _dio.get('api/Quiz/admin/questions', options: await _auth());

  Future<Response> adminAddQuestion(Map<String, dynamic> body) async =>
      _dio.post('api/Quiz/admin/questions', data: body, options: await _auth());

  Future<Response> adminUpdateQuestion(int id, Map<String, dynamic> body) async =>
      _dio.put('api/Quiz/admin/questions/$id', data: body, options: await _auth());

  Future<Response> adminDeleteQuestion(int id) async =>
      _dio.delete('api/Quiz/admin/questions/$id', options: await _auth());

  Future<Response> adminToggleQuestion(int id) async =>
      _dio.patch('api/Quiz/admin/questions/$id/toggle', options: await _auth());

  // Tourist
  Future<Response> getQuiz() async =>
      _dio.get('api/Quiz/play', options: await _auth());

  Future<Response> submitQuiz(List<Map<String, dynamic>> answers) async =>
      _dio.post('api/Quiz/submit',
          data: {'answers': answers}, options: await _auth());

  Future<Response> getHistory() async =>
      _dio.get('api/Quiz/history', options: await _auth());
}