import 'package:flutter/material.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/Bookings.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/Homestays.dart';
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

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<PageConfig> _pages = [
    PageConfig(icon: Icon(Icons.dashboard),title: "Dashboard", child: Dashboard()),
    PageConfig(icon: Icon(Icons.people),title: "Users", child: UserManagementPage(), actions: [Text("Total Users: 120")]),
    PageConfig(icon: Icon(Icons.map_outlined),title: "Sites", child: Sites()),
    PageConfig(icon: Icon(Icons.menu_book_outlined),title: "Stories", child: Stories()),
    PageConfig(icon: Icon(Icons.house),title: "Homestays", child: Homestays()),
    PageConfig(icon: Icon(Icons.calendar_month),title: "Bookings", child: Bookings(), actions: [Text("Today: 35")]),
    PageConfig(icon: Icon(Icons.payment),title: "Payments", child: Payments()),
    PageConfig(icon: Icon(Icons.quiz),title: "Quizzes", child: Quizzes()),
    PageConfig(icon: Icon(Icons.reviews),title: "Reviews", child: Reviews()),
    PageConfig(icon: Icon(Icons.report_sharp),title: "Reports", child: Reports()),
    PageConfig(icon: Icon(Icons.settings),title: "Settings", child: Settings()),
  ];

  void _onItemTapped(int index) {
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
    );
  }
}