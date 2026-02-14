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
      create: (_) => UserBloc()..add(FetchUsers()),
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            subtitleNotifier.value = "Loading users...";
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserLoaded) {
            subtitleNotifier.value = "Total: ${state.users.length} users";
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search users...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (query) {
                      // optional: trigger search event in bloc
                      // context.read<UserBloc>().add(SearchUsers(query));
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // User list
                Expanded(
                  child: ListView.builder(
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      final User user = state.users[index];
                      return Card(
                        color: const Color(0xFFF5F5F5),
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(user.name[0].toUpperCase()),
                          ),
                          title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Chip(
                                    label: Text(user.role),
                                    backgroundColor:_getRoleColor(user.role),
                                    labelStyle: TextStyle(
                                      color: _getTextColor(user.role),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: const Text("Active"),
                                    backgroundColor: Colors.lightGreenAccent.shade100,
                                    labelStyle: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.email, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(user.email),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text((user.phone!=null && user.phone!="")?user.phone!:"Phone number not set",style: TextStyle(color: Colors.black,fontStyle: FontStyle.italic,fontWeight: FontWeight.w400),),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              // context.read<UserBloc>().add(DeleteUser(user.id));
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is UserError) {
            subtitleNotifier.value = "Error loading users";
            return Center(child: Text(state.message));
          }
          subtitleNotifier.value = "No users yet";
          return const Center(child: Text("Users to manage"));
        },
      ),
    );
  }

  Color _getRoleColor(String role){
    switch(role.toLowerCase()){
      case "admin":
        return Colors.green.shade100;
      case "tourist":
        return Colors.blue.shade100;
      case "owner":
        return Colors.lightGreenAccent.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
  Color _getTextColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.blueGrey.shade800;
      case 'tourist':
        return Colors.blue.shade800;
      case 'owner':
        return Colors.black;
      default:
        return Colors.grey.shade800;
    }
  }
}