import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/user/user_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/user/user_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/user/user_state.dart';
import 'package:lokyatra_frontend/data/models/user.dart';

class UserManagementPage extends StatefulWidget {
  final ValueNotifier<String?> subtitleNotifier;
  const UserManagementPage({super.key, required this.subtitleNotifier});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  String _searchQuery = "";
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserBloc()..add(FetchUsers()),
      child: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserInitial) {
            widget.subtitleNotifier.value = "Initializing...";
          } else if (state is UserLoading) {
            widget.subtitleNotifier.value = "Loading users...";
          } else if (state is UserLoaded) {
            widget.subtitleNotifier.value = state.users.isEmpty
                ? "No users yet"
                : "Total: ${state.users.length} users";
          }
          else if(state is UserDeleted){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("User deleted successfully")),
            );
            context.read<UserBloc>().add(FetchUsers());
          }
          else if(state is UserError){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is UserInitial) {
            return const Center(child: Text("Preparing User List..."));
          } else if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserLoaded) {
            if (state.users.isEmpty) {
              return const Center(child: Text("Users to manage"));
            }

            final filteredUsers = state.users.where((user) {
              final query = _searchQuery.toLowerCase();
              return user.name.toLowerCase().contains(query) ||
                  user.email.toLowerCase().contains(query) ||
                  user.role.toLowerCase().contains(query);
            }).toList();

            final suggestions = _searchQuery.isEmpty
                ? []
                : state.users.where((user) {
              final query = _searchQuery.toLowerCase();
              return user.name.toLowerCase().contains(query) ||
                  user.email.toLowerCase().contains(query) ||
                  user.role.toLowerCase().contains(query);
            }).take(5).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      TextField(
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: "Search users...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (query) {
                          setState(() {
                            _searchQuery = query;
                          });
                        },
                      ),
                      if (_focusNode.hasFocus && suggestions.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: suggestions.length,
                            itemBuilder: (context, index) {
                              final user = suggestions[index];
                              return ListTile(
                                title: Text(user.name),
                                subtitle: Text(user.email),
                                onTap: () {
                                  setState(() {
                                    _searchQuery = user.name;
                                    _focusNode.unfocus();
                                  });
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<UserBloc>().add(FetchUsers());
                    },
                    child: ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final User user = filteredUsers[index];
                        return Card(
                          color: const Color(0xFFF5F5F5),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(user.name[0].toUpperCase()),
                            ),
                            title: Text(user.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Chip(
                                      label: Text(user.role),
                                      backgroundColor: _getRoleColor(user.role),
                                      labelStyle: TextStyle(
                                        color: _getTextColor(user.role),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Chip(
                                      label: Text(
                                          (user.isActive ?? false)
                                              ? "Active"
                                              : "Inactive"),
                                      backgroundColor: (user.isActive ?? false)
                                          ? Colors.lightGreenAccent.shade100
                                          : Colors.red.shade100,
                                      labelStyle: TextStyle(
                                        color: (user.isActive ?? false)
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.email,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(user.email),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.phone,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      (user.phone != null &&
                                          user.phone!.isNotEmpty)
                                          ? user.phone!
                                          : "Phone number not set",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                context.read<UserBloc>().add(DeleteUsers(user.id));
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          } else if (state is UserError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text("Users to manage"));
        },
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
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