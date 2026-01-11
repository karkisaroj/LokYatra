

import 'package:equatable/equatable.dart';

import '../../../../data/models/register.dart';

abstract class AuthState  extends Equatable{
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState{}

class AuthLoading extends AuthState{}

class RegisterSuccess extends AuthState{
  final RegisterUser user;
  RegisterSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class LoginSuccess extends AuthState{
  final String accessToken;
  LoginSuccess(this.accessToken);

  @override
  List<Object?> get props => [accessToken];
}

class AuthError extends AuthState{
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}


class LogoutSuccess extends AuthState{}