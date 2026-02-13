// // lib/bloc/user/user_bloc.dart
// import 'dart:developer';
//
// import 'package:bloc/bloc.dart';
// import 'package:dio/dio.dart';
// import 'package:lokyatra_frontend/core/constants.dart';
// import 'package:lokyatra_frontend/data/models/register.dart';
// import 'package:lokyatra_frontend/presentation/screens/test/Bloc/userEvent.dart';
// import 'package:lokyatra_frontend/presentation/screens/test/Bloc/userState.dart';
//
// class UserBloc extends Bloc<UserEvent, UserState> {
//   UserBloc() : super(UserInitial()) {
//     on<ButtonClicked>(_onButtonClicked);
//   }
//
//   final Dio dio = Dio(BaseOptions(
//     baseUrl: getBaseUrl(),
//     connectTimeout: connectTimeout,
//     receiveTimeout: receiveTimeout,
//   ));
//
//   Future<void> _onButtonClicked(ButtonClicked event, Emitter<UserState> emit) async {
//     emit(UserLoading());
//     try {
//       final response = await dio.get('getUsers');
//       if (response.statusCode == 200) {
//         log(response.data.toString());
//         final List<dynamic> data = response.data;
//
//         final List<RegisterUser> users = data
//             .map((json) => RegisterUser.fromJson(json as Map<String, dynamic>))
//             .toList();
//         emit(UserLoaded(users));
//       } else {
//         emit(UserError('Server error: ${response.statusCode}'));
//       }
//     } on DioException catch (e) {
//       String errorMsg = 'Network error';
//       if (e.type == DioExceptionType.connectionTimeout) {
//         errorMsg = 'Connection timeout';
//       } else if (e.type == DioExceptionType.receiveTimeout) {
//         errorMsg = 'Receive timeout';
//       } else if (e.response != null) {
//         errorMsg = 'Error: ${e.response?.statusCode} - ${e.response?.data}';
//       } else {
//         errorMsg = e.message ?? 'Unknown error';
//       }
//       emit(UserError('Failed to fetch users: $errorMsg'));
//     } catch (e) {
//       emit(UserError('Unexpected error: $e'));
//     }
//   }
// }