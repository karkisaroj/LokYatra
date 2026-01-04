import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/presentation/screens/test/Bloc/usersBloc.dart';
import 'package:lokyatra_frontend/presentation/splash/splash_screen.dart';
import 'package:bloc/bloc.dart';

void main() {
  runApp(
      BlocProvider<UserBloc>(
          create: (context) => UserBloc(),
          child: SplashScreen()));

}

