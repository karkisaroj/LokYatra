import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/user/user_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/user/user_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/user/user_state.dart';
import 'package:lokyatra_frontend/data/models/user.dart';

class UserManagementPage extends StatelessWidget {
  final ValueNotifier<String?> subtitleNotifier;
  const UserManagementPage({super.key, required this.subtitleNotifier});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserBloc()..add(FetchUsers()), // this create and that trigger fetch immediately
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            subtitleNotifier.value = "Loading users...";
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserLoaded) {
            subtitleNotifier.value = "Total Users: ${state.users.length}";
            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final User user = state.users[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(user.name[0].toUpperCase())),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: Text(user.role),
                );
              },
            );
          } else if (state is UserError) {
            subtitleNotifier.value = "Error loading users";
            return Center(child: Text(state.message));
          }
          // Initial state
          subtitleNotifier.value = "No users yet";
          return const Center(child: Text("Users to manage"));
        },
      ),
    );
  }
}