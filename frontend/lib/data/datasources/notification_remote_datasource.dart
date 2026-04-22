import 'package:dio/dio.dart';
import '../../core/services/constants.dart';
import '../../presentation/widgets/Helpers/secure_storage_service.dart';

class NotificationRemoteDatasource {
  final _dio = Dio(BaseOptions(baseUrl: apiBaseUrl));

  Future<Options> _auth() async {
    final token = await SecureStorageService.getAccessToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<Response> getMyNotifications() async =>
      _dio.get('/api/Notification', options: await _auth());

  Future<Response> markRead(int id) async =>
      _dio.patch('/api/Notification/$id/read', options: await _auth());

  Future<Response> markAllRead() async =>
      _dio.patch('/api/Notification/read-all', options: await _auth());

  Future<Response> deleteNotification(int id) async =>
      _dio.delete('/api/Notification/$id', options: await _auth());

  Future<Response> clearAll() async =>
      _dio.delete('/api/Notification/clear-all', options: await _auth());
}
