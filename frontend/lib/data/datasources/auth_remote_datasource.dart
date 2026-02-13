// import 'package:dio/dio.dart';
// import 'package:lokyatra_frontend/core/constants.dart';
//
// class AuthRemoteDatasource {
//   final Dio _dio;
//   AuthRemoteDatasource():_dio=Dio(BaseOptions(
//     baseUrl: apiBaseUrl,
//     connectTimeout: connectTimeout,
//     receiveTimeout: receiveTimeout,
//     sendTimeout: sendTimeout,
//     contentType: "application/json",
//     responseType: ResponseType.json,
//     headers: headers,
//   )){
//     _dio.interceptors.add(LogInterceptor(responseBody: true));
//   }
//   Future<Response> register(Map<String, dynamic> userData) {
//     return _dio.post('register', data: userData);
//   }
//
//   Future<Response> login(Map<String, dynamic> loginData) {
//     return _dio.post('login', data: loginData);
//   }
//
// }