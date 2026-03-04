import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lokyatra_frontend/core/services/constants.dart';
import 'package:lokyatra_frontend/core/services/sqlite_service.dart';
import 'package:lokyatra_frontend/data/models/register.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/SecureStorageService.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<RegisterButtonClicked>(_onRegister);
    on<LoginButtonClicked>(_onLogin);
    on<LogoutButtonClicked>(_onLogout);
  }

  final Dio _dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: connectTimeout,
    receiveTimeout: receiveTimeout,
    contentType: 'application/json',
    responseType: ResponseType.json,
  ))..interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    requestHeader: false,
  ));

  Future<void> _onRegister(
      RegisterButtonClicked event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _dio.post(registerEndpoint, data: event.user.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        final registeredUser = RegisterUser.fromJson(response.data as Map<String, dynamic>);
        emit(RegisterSuccess(registeredUser));
      } else {
        emit(AuthError('Server error: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      emit(AuthError(_parseDioError(e)));
    } catch (e) {
      emit(AuthError('Unexpected error: $e'));
    }
  }

  Future<void> _onLogin(
      LoginButtonClicked event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final loginRes = await _dio.post(
        loginEndpoint,
        data: {'email': event.email, 'password': event.password},
      );

      if (loginRes.statusCode != 200) {
        emit(AuthError('Login failed: ${loginRes.statusCode}'));
        return;
      }

      final accessToken = loginRes.data['accessToken'] as String;
      final refreshToken = loginRes.data['refreshToken'] as String;
      await SecureStorageService.saveTokens(accessToken, refreshToken);

      try {
        final profileRes = await _dio.get(
          'api/User/current-user',
          options: Options(headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json',
          }),
        );
        if (profileRes.statusCode == 200) {
          final d = profileRes.data as Map<String, dynamic>;
          await SqliteService().put("user_name", d['name'] ?? '');
          await SqliteService().put("user_email", d['email'] ?? '');
          await SqliteService().put("user_phone", d['phoneNumber'] ?? '');
          await SqliteService().put("user_image", d['profileImage'] as String? ?? '');
        }
      } catch (e) {
        final decoded = JwtDecoder.decode(accessToken);
        await SqliteService().put("user_name", decoded['name'] ?? '');
        await SqliteService().put("user_email", event.email);
      }

      final role = JwtDecoder.decode(accessToken)['role'] as String?;
      if (role == 'admin') {
        emit(AdminLoginSuccess(accessToken));
      } else if (role == 'tourist') {
        emit(TouristLoginSuccess(accessToken));
      } else if (role == 'owner') {
        emit(OwnerLoginSuccess(accessToken));
      } else {
        emit(AuthError('Unknown role: $role'));
      }
    } on DioException catch (e) {
      emit(AuthError(_parseDioError(e)));
    } catch (e) {
      emit(AuthError('Unexpected error: $e'));
    }
  }

  Future<void> _onLogout(
      LogoutButtonClicked event, Emitter<AuthState> emit) async {
    try {
      final accessToken = await SecureStorageService.getAccessToken();
      await _dio.post(
        logoutEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } catch (_) {}
    finally {
      await SecureStorageService.deleteTokens();
      await SqliteService().clearAllCache();
      emit(LogoutSuccess());
    }
  }

  String _parseDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) return 'Connection timeout';
    if (e.type == DioExceptionType.receiveTimeout) return 'Receive timeout';
    if (e.type == DioExceptionType.connectionError) return 'Cannot reach server. Check your network.';
    if (e.response != null) {
      final data = e.response?.data;
      if (data is String && data.isNotEmpty) return data;
      return 'Error ${e.response?.statusCode}';
    }
    return e.message ?? 'Unknown error';
  }
}