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

class AdminPageWrapper extends StatefulWidget {
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
  State<AdminPageWrapper> createState() => _AdminPageWrapperState();
}

class _AdminPageWrapperState extends State<AdminPageWrapper> {
  bool _progressShown = false;

  void _openProgress() {
    if (_progressShown) return;
    _progressShown = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Center(
          child: SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    ).then((_) {
      _progressShown = false;
    });
  }

  void _closeProgress() {
    if (_progressShown) {
      Navigator.of(context, rootNavigator: true).pop();
      _progressShown = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = widget.pages[widget.selectedIndex];

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Inside your BlocListener for AuthBloc
        if (state is LogoutSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // 1. Close the progress dialog first if it's still open
            if (_progressShown) {
              Navigator.of(context).pop();
            }
            // 2. Then navigate to Login and clear the stack
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          });


      } else if (state is AuthError) {
          _closeProgress();
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
            valueListenable: widget.subtitleNotifier,
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
                        for (int i = 0; i < widget.pages.length; i++)
                          ListTile(
                            leading: widget.pages[i].icon,
                            title: Text(widget.pages[i].title),
                            selected: widget.selectedIndex == i,
                            selectedColor: Colors.blueGrey,
                            onTap: () {
                              widget.onItemTapped(i);
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
                      onPressed: _progressShown
                          ? null
                          : () {
                        // Show a blocking progress indicator immediately
                        _openProgress();
                        // Dispatch logout event
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