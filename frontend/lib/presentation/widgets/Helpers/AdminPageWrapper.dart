import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../state_management/Bloc/auth/auth_bloc.dart';
import '../../state_management/Bloc/auth/auth_event.dart';
import '../../state_management/Bloc/auth/auth_state.dart';

class PageConfig {
  final String title;
  final String? subtitle;
  final Icon icon;
  final Widget child;
  final List<Widget>? actions;

  PageConfig({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.child,
    this.actions,
  });
}

class AdminPageWrapper extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final List<PageConfig> pages;
  final ValueNotifier<String?> subtitleNotifier;

  const AdminPageWrapper({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.pages,
    required this.subtitleNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final currentPage = pages[selectedIndex];

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          // Navigate only when logout succeeds
          Navigator.pushReplacementNamed(context, '/login');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),

        appBar: AppBar(
          backgroundColor: Colors.white54,
          title: ValueListenableBuilder<String?>(
            valueListenable: subtitleNotifier,
            builder: (context, subtitle, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentPage.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if ((subtitle ?? currentPage.subtitle) != null &&
                    (subtitle ?? currentPage.subtitle)!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      subtitle ?? currentPage.subtitle!,
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ),
              ],
            ),
          ),
          actions: currentPage.actions,
        ),

        drawer: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return Drawer(
              backgroundColor: Colors.white,
              width: isMobile ? 220 : 280,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Welcome \nAdmin",
                            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                        SizedBox(width: 5,),
                        Icon(Icons.admin_panel_settings, size: 50,),
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
                            selectedColor: Colors.blueGrey,
                            onTap: () {
                              onItemTapped(i);
                              Navigator.pop(context); // close drawer
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
                        // Dispatch logout event only
                        context.read<AuthBloc>().add(LogoutButtonClicked());
                      },
                      icon: const Icon(Icons.logout),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      label: const Text("Logout", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        body: currentPage.child,
      ),
    );
  }
}