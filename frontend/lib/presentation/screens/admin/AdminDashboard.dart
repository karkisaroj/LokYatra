import 'package:flutter/material.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/Bookings.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/Adminhomestaydetailpage.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/Payments.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/Quizzes.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/Reports.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/Reviews.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/Settings.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/Sites.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/Stories.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/UserManagementPage.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/dashboard.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/AdminPageWrapper.dart';

import 'Adminhomestays.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final ValueNotifier<String?> subtitleNotifier = ValueNotifier(null);

  late final List<PageConfig> _pages = [
    PageConfig(
      icon: const Icon(Icons.dashboard),
      title: "Dashboard",
      subtitle: "Welcome to LokYatra Admin Panel",
      child: const Dashboard(),
    ),
    PageConfig(
      icon: const Icon(Icons.people),
      title: "Users",
      child: UserManagementPage(subtitleNotifier: subtitleNotifier),
    ),
    PageConfig(icon: const Icon(Icons.map_outlined), title: "Sites", child: const Sites()),
    PageConfig(icon: const Icon(Icons.menu_book_outlined), title: "Stories", child: const Stories()),
    PageConfig(icon: const Icon(Icons.house), title: "Homestays", child: Homestays(subtitleNotifier: subtitleNotifier)),
    PageConfig(icon: const Icon(Icons.calendar_month), title: "Bookings", child: const Bookings()),
    PageConfig(icon: const Icon(Icons.payment), title: "Payments", child: const Payments()),
    PageConfig(icon: const Icon(Icons.quiz), title: "Quizzes", child: const Quizzes()),
    PageConfig(icon: const Icon(Icons.reviews), title: "Reviews", child: const Reviews()),
    PageConfig(icon: const Icon(Icons.report_sharp), title: "Reports", child: const Reports()),
    PageConfig(icon: const Icon(Icons.settings), title: "Settings", child: const Settings()),
  ];

  void _onItemTapped(int index) {
    subtitleNotifier.value = null;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageWrapper(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      pages: _pages,
      subtitleNotifier: subtitleNotifier,
    );
  }
}