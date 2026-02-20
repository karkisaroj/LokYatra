import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lokyatra_frontend/core/constants.dart';
import 'package:lokyatra_frontend/data/datasources/user_remote_datasource.dart';
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

  final Dio dio = Dio(BaseOptions(
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
      final response =
      await dio.post(registerEndpoint, data: event.user.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        final registeredUser =
        RegisterUser.fromJson(response.data as Map<String, dynamic>);
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
      final response = await dio.post(
        loginEndpoint,
        data: {'email': event.email, 'password': event.password},
      );

      if (response.statusCode == 200) {
        final accessToken = response.data['accessToken'] as String;
        final refreshToken = response.data['refreshToken'] as String;

        await SecureStorageService.saveTokens(accessToken, refreshToken);

        try {
          final profileRes = await UserRemoteDatasource().getMe();
          if (profileRes.statusCode == 200) {
            final data = profileRes.data as Map<String, dynamic>;
            await SecureStorageService.saveUserProfile(
              name: data['name'] ?? '',
              email: data['email'] ?? '',
              profileImage: data['profileImage'] ?? '',
              phoneNumber: data['phoneNumber'] ?? '',
            );
          }
        } catch (e) {
          emit(AuthError('Error fetching user profile: $e'));
        }

        final decodedToken = JwtDecoder.decode(accessToken);
        final role = decodedToken['role'] as String?;

        if (role == 'admin') {
          emit(AdminLoginSuccess(accessToken));
        } else if (role == 'tourist') {
          emit(TouristLoginSuccess(accessToken));
        } else if (role == 'owner') {
          emit(OwnerLoginSuccess(accessToken));
        } else {
          emit(AuthError('Unknown role: $role'));
        }
      } else {
        emit(AuthError('Login failed: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      emit(AuthError(_parseDioError(e)));
    } catch (e) {
      emit(AuthError('Unexpected error: $e'));
    }
  }

  Future<void> _onLogout(
      LogoutButtonClicked event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final accessToken = await SecureStorageService.getAccessToken();
      await dio.post(
        logoutEndpoint,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      await SecureStorageService.deleteTokens();
      emit(LogoutSuccess());
    } catch (_) {
      await SecureStorageService.deleteTokens();
      emit(LogoutSuccess());
    }
  }

  String _parseDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) return 'Connection timeout';
    if (e.type == DioExceptionType.receiveTimeout) return 'Receive timeout';
    if (e.type == DioExceptionType.connectionError) {
      return 'Cannot reach server. Check your network.';
    }
    if (e.response != null) {
      final data = e.response?.data;
      if (data is String && data.isNotEmpty) return data;
      return 'Error ${e.response?.statusCode}';
    }
    return e.message ?? 'Unknown error';
  }
}