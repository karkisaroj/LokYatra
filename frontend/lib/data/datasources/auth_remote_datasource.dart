import 'package:dio/dio.dart';
import 'package:lokyatra_frontend/core/constants.dart';

class AuthRemoteDatasource {
  final Dio _dio;
  AuthRemoteDatasource():_dio=Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: connectTimeout,
    receiveTimeout: receiveTimeout,
    sendTimeout: sendTimeout,
    headers: headers,
  )){
    _dio.interceptors.add(LogInterceptor(responseBody: true));
  }

}