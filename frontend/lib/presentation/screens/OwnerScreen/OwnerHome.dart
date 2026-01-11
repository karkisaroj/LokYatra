import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/auth/auth_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/auth/auth_event.dart';

class OwnerHome extends StatelessWidget {
  const OwnerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("This is owner screen"),actions: [ IconButton(onPressed: (){
        context.read<AuthBloc>().add(LogoutButtonClicked());
        Navigator.pushReplacementNamed(context, '/login');
      }, icon: Icon(Icons.logout))])
    );
  }
}
