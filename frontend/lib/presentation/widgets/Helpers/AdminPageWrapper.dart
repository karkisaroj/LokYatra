import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../state_management/Bloc/auth/auth_bloc.dart';
import '../../state_management/Bloc/auth/auth_event.dart';

class PageConfig {
  final String title;
  final Icon icon;
  final Widget child;
  final List<Widget>? actions;

  PageConfig({
    required this.title,
    required this.icon,
    required this.child,
    this.actions,
  });
}

class AdminPageWrapper extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final List<PageConfig> pages;

  const AdminPageWrapper({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    final currentPage = pages[selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentPage.title),
        actions: currentPage.actions,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    "Welcome Admin",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.admin_panel_settings),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (int i = 0; i < pages.length; i++)
                    ListTile(
                      leading: pages[i].icon,
                      title: Text(pages[i].title),
                      selected: selectedIndex == i,
                      trailing: const Icon(Icons.arrow_right),
                      onTap: () {
                        onItemTapped(i);
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
            ),

            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: TextButton.icon(
                onPressed: () {
                  BlocProvider.of<AuthBloc>(context).add(LogoutButtonClicked());
                  Navigator.pushNamed(context, '/login');
                },
                icon: const Icon(Icons.logout),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                label: const Text("Logout" ,style: TextStyle(color: Colors.black),),
              ),
            ),
          ],
        ),
      ),
      body: currentPage.child,
    );
  }
}