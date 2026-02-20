import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lokyatra_frontend/core/constants.dart';
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
      // Step 1: Login
      final loginRes = await _dio.post(
        loginEndpoint,
        data: {'email': event.email, 'password': event.password},
      );

      if (loginRes.statusCode != 200) {
        emit(AuthError('Login failed: ${loginRes.statusCode}'));
        return;
      }

      final accessToken  = loginRes.data['accessToken']  as String;
      final refreshToken = loginRes.data['refreshToken'] as String;

      // Step 2: Save tokens
      await SecureStorageService.saveTokens(accessToken, refreshToken);

      // Step 3: Fetch profile using the fresh token directly (no storage read)
      try {
        final profileRes = await _dio.get(
          'api/User/me',
          options: Options(headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json',
          }),
        );

        print('=== getMe status: ${profileRes.statusCode}');
        print('=== getMe data: ${profileRes.data}');

        if (profileRes.statusCode == 200) {
          final d = profileRes.data as Map<String, dynamic>;
          final imageUrl = d['profileImage'] as String? ?? '';
          print('=== profileImage from server: "$imageUrl"');

          await SecureStorageService.saveUserProfile(
            name:         d['name']         as String? ?? '',
            email:        d['email']         as String? ?? '',
            profileImage: imageUrl,
            phoneNumber:  d['phoneNumber']   as String? ?? '',
          );

          final check = await SecureStorageService.getProfileImage();
          print('=== profileImage saved in prefs: "$check"');
        }
      } catch (e) {
        print('=== getMe FAILED: $e');
        // Save at least name/email from token so profile page isn't empty
        final decoded = JwtDecoder.decode(accessToken);
        await SecureStorageService.saveUserProfile(
          name:  decoded['name']  as String? ?? '',
          email: event.email,
        );
      }

      // Step 4: Emit success — prefs are written, navigation happens now
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
    emit(AuthLoading());
    try {
      final accessToken = await SecureStorageService.getAccessToken();
      await _dio.post(
        logoutEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } catch (_) {
      // server call failing is fine — clear locally anyway
    } finally {
      await SecureStorageService.deleteTokens();
      emit(LogoutSuccess());
    }
  }

  String _parseDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) return 'Connection timeout';
    if (e.type == DioExceptionType.receiveTimeout)    return 'Receive timeout';
    if (e.type == DioExceptionType.connectionError)   return 'Cannot reach server. Check your network.';
    if (e.response != null) {
      final data = e.response?.data;
      if (data is String && data.isNotEmpty) return data;
      return 'Error ${e.response?.statusCode}';
    }
    return e.message ?? 'Unknown error';
  }
}