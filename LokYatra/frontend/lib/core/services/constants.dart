const String _prodBaseUrl = "https://lokyatra-production.up.railway.app";

const bool _useLocalServer = false;
const String _localBaseUrl = "http://10.0.2.2:5257";

const String _envApiBaseUrl = String.fromEnvironment("API_BASE_URL");

String getBaseUrl() {
  if (_envApiBaseUrl.isNotEmpty) return _envApiBaseUrl;
  if (_useLocalServer) return _localBaseUrl;
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
};
