import 'dart:io';
import 'package:flutter/foundation.dart';

const String _serverIp = "192.168.10.100";
const int _serverPort = 5257;

String getBaseUrl() {
  if (kIsWeb) {
    return "http://localhost:$_serverPort";
  } else if (Platform.isAndroid) {
    return "http://$_serverIp:$_serverPort";
  } else {
    return "http://localhost:$_serverPort";
  }
}

String get apiBaseUrl => "${getBaseUrl()}/";
String get imageBaseUrl => getBaseUrl();

// Standard timeouts for normal API calls
const Duration connectTimeout = Duration(seconds: 30);
const Duration receiveTimeout = Duration(seconds: 60);
const Duration sendTimeout    = Duration(seconds: 60);

const Duration uploadReceiveTimeout = Duration(minutes: 3);
const Duration uploadSendTimeout    = Duration(minutes: 3);

const String loginEndpoint    = "api/Auth/login";
const String registerEndpoint = "api/Auth/register";
const String logoutEndpoint   = "api/Auth/logout";

const String getUsersEndpoint   = "api/User/getUsers";
const String deleteUserEndpoint = "api/User/deleteUser";

const String sitesBasePath     = "api/Sites";
const String storiesBasePath   = "api/Stories";
const String homestaysBasePath = "api/Homestays";

const Map<String, String> headers = {
  "Accept": "application/json",
};