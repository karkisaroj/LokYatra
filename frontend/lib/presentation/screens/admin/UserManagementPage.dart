import 'package:flutter/material.dart';

class UserManagementPage extends StatelessWidget {
  final ValueNotifier<String?> subtitleNotifier;
  const UserManagementPage({super.key, required this.subtitleNotifier});

  @override
  Widget build(BuildContext context) {
    int totalUsers = 120;
    subtitleNotifier.value = "Total Users: $totalUsers";

    return Center(child: Text("Users to manage"));
  }
}