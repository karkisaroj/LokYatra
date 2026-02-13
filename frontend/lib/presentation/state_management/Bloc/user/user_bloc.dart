

import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:lokyatra_frontend/core/constants.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/user/user_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/user/user_state.dart';

import '../../../../data/models/user.dart';

class UserBloc extends Bloc<UserEvent, UserState>{
  UserBloc():super(UserInitial()){
    on<FetchUsers>(_onFetchUsers);
  }

  final Dio dio=Dio(BaseOptions(
    baseUrl: getBaseUrl(),
    connectTimeout: connectTimeout,
    receiveTimeout: receiveTimeout,
    contentType: "application/json",
    responseType: ResponseType.json,
    headers: headers
  ));
  
  Future<void> _onFetchUsers(FetchUsers event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try{
      final response=await dio.get(getUsersEndpoint);
      if(response.statusCode==200){
        final List<dynamic>data=response.data;
        final users=data.map((json)=>User.fromJson(json)).toList();
        emit(UserLoaded(users));
      }else{
        emit(UserError("Failed to fetch Users: Status code: ${response.statusCode}"));
      }
    }
    catch(e){
      emit(UserError("Error occurred $e"));
    }
  }

}
