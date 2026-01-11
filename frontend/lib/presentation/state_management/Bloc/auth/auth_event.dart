import 'package:equatable/equatable.dart';
import 'package:lokyatra_frontend/data/models/register.dart';

abstract class AuthEvent extends Equatable{
  @override
  List<Object?> get props => [];
}

class RegisterButtonClicked extends AuthEvent{
  final RegisterUser user;

  RegisterButtonClicked(this.user);

  @override
  List<Object?> get props => [user];
}

class LoginButtonClicked extends AuthEvent{
  final String email;
  final String password;

  LoginButtonClicked(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class LogoutButtonClicked extends AuthEvent{

}