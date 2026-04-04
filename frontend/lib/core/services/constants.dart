import 'package:flutter/foundation.dart';
const String _prodBaseUrl = "https://lokyatra-production.up.railway.app";

const String _localIp = "192.168.1.65";
const int _localPort = 5257;

// Optional override from build/run command: in case the railway token will expire
// flutter run --dart-define=API_BASE_URL=http://192.168.1.65:5257
// flutter build web --dart-define=API_BASE_URL=https://lokyatra-production.up.railway.app
const String _envApiBaseUrl = String.fromEnvironment("API_BASE_URL");

String getBaseUrl() {
  if (_envApiBaseUrl.isNotEmpty) return _envApiBaseUrl;

  // Always use production URL for now to allow device app login to work!
  return _prodBaseUrl;
}

String get apiBaseUrl => "${getBaseUrl()}/";
String get imageBaseUrl => getBaseUrl();

const Duration connectTimeout = Duration(seconds: 30);
const Duration receiveTimeout = Duration(seconds: 60);
const Duration sendTimeout = Duration(seconds: 60);

const Duration uploadReceiveTimeout = Duration(minutes: 3);
const Duration uploadSendTimeout = Duration(minutes: 3);

const String loginEndpoint = "api/Auth/login";
const String registerEndpoint = "api/Auth/register";
const String logoutEndpoint = "api/Auth/logout";

const String getUsersEndpoint = "api/User/getUsers";
const String deleteUserEndpoint = "api/User/deleteUser";

const String sitesBasePath = "api/Sites";
const String storiesBasePath = "api/Stories";
const String homestaysBasePath = "api/Homestays";
const String forgetPassword = "api/Auth/forgot-password";
const String resetPassword = "api/Auth/reset-password";

const Map<String, String> headers = {
  "Accept": "application/json",
  "Content-Type": "application/json",
};