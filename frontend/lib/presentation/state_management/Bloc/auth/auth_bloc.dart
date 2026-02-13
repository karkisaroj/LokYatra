import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lokyatra_frontend/core/constants.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/SecureStorageService.dart';
import '../../../../data/models/register.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  AuthBloc() : super(AuthInitial()) {
    on<RegisterButtonClicked>(_onRegister);
    on<LoginButtonClicked>(_onLogin);
    on<LogoutButtonClicked>(_onLogout);
  }

  final Dio dio = Dio(BaseOptions(
    baseUrl: getBaseUrl(),
    connectTimeout: connectTimeout,
    receiveTimeout: receiveTimeout,
    contentType: "application/json",
    responseType: ResponseType.json,
  ));

  Future<void> _onRegister(RegisterButtonClicked event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await dio.post(registerEndpoint, data: event.user.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> json = response.data;
        final registeredUser = RegisterUser.fromJson(json);
        emit(RegisterSuccess(registeredUser));
      } else {
        emit(AuthError('Server error: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      String errorMessage = "Network error";
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = "Connection timeout";
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = "Receive timeout";
      } else if (e.response != null) {
        errorMessage = "Error: ${e.response?.statusCode} - ${e.response?.data}";
      } else {
        errorMessage = e.message ?? 'Unknown error';
      }
      emit(AuthError('Failed to register user: $errorMessage'));
    } catch (e) {
      emit(AuthError('Unexpected error: $e'));
    }
  }

  Future<void> _onLogin(LoginButtonClicked event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final loginData = {
        'email': event.email,
        'password': event.password,
      };

      final response = await dio.post(loginEndpoint, data: loginData);

      if (response.statusCode == 200) {
        final accessToken = response.data['accessToken'];
        final refreshToken = response.data['refreshToken'];
        await SecureStorageService.saveTokens(accessToken, refreshToken);

        final decodedToken = JwtDecoder.decode(accessToken);
        final role = decodedToken['role'];

        if (role == 'admin') {
          emit(AdminLoginSuccess(accessToken));
        } else if (role == 'tourist') {
          emit(TouristLoginSuccess(accessToken));
        } else if (role == 'owner') {
          emit(OwnerLoginSuccess(accessToken));
        } else {
          emit(AuthError("Invalid role"));
        }
      } else {
        emit(AuthError("Login failed: ${response.statusCode}"));
      }
    } on DioException catch (e) {
      emit(AuthError("Network error: ${e.message}"));
    } catch (e) {
      emit(AuthError("Unexpected error: $e"));
    }
  }

  Future<void> _onLogout(LogoutButtonClicked event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await SecureStorageService.deleteTokens();
      emit(LogoutSuccess());
    } catch (e) {
      emit(AuthError("Failed to logout: $e"));
    }
  }
}