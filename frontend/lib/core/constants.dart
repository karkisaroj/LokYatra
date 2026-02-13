import 'dart:io';
import 'package:flutter/foundation.dart';

const String _serverIp = "192.168.1.66";
const int _serverPort = 5257;

String getBaseUrl() {
  if (kIsWeb) {
    return "http://localhost:$_serverPort/api/Auth/";
  } else if (Platform.isAndroid) {
    return "http://$_serverIp:$_serverPort/api/Auth/";
  } else {
    return "http://localhost:$_serverPort/api/Auth/";
  }
}

String get apiBaseUrl => getBaseUrl().replaceAll("/api/Auth/", "");

//below are endpoints paths
const String loginEndpoint = "/api/Auth/login";
const String registerEndpoint = "/api/Auth/register";
const String getUsersEndpoint = "/api/Auth/getUsers";

const Map<String, String> headers = {
  "Content-Type": "application/json",
  "Accept": "application/json",
};

const Duration connectTimeout = Duration(seconds: 10);
const Duration receiveTimeout = Duration(seconds: 10);
const Duration sendTimeout = Duration(seconds: 10);