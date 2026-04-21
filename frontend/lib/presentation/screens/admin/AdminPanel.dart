import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/AdminBookings.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/AdminPayments.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/AdminAddQuizzes.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/AdminReports.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/AdminReviews.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/AdminSettings.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/AdminSites.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/AdminStories.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/UserManagementPage.dart';
import 'package:lokyatra_frontend/presentation/screens/admin/AdminDashboard.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/AdminPageWrapper.dart';
import 'HomestayApproval.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final ValueNotifier<String?> subtitleNotifier = ValueNotifier(null);

  late final List<PageConfig> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      PageConfig(
        icon: const Icon(Icons.dashboard),
        title: 'Dashboard',
        subtitle: 'Welcome to LokYatra Admin Panel',
        child: const Dashboard(),
      ),
      PageConfig(
        icon: const Icon(Icons.people),
        title: 'Users',
        child: UserManagementPage(subtitleNotifier: subtitleNotifier),
      ),
      PageConfig(
        icon: const Icon(Icons.map_outlined),
        title: 'Sites',
        child: const AdminSites(),
      ),
      PageConfig(
        icon: const Icon(Icons.menu_book_outlined),
        title: 'Stories',
        child: const AdminStories(),
      ),
      PageConfig(
        icon: const Icon(Icons.house),
        title: 'Homestay Approval',
        child: HomestayApproval(subtitleNotifier: subtitleNotifier),
      ),
      PageConfig(
        icon: const Icon(Icons.calendar_month),
        title: 'Bookings',
        child: const AdminBookings(),
      ),
      PageConfig(
        icon: const Icon(Icons.payment),
        title: 'Payments',
        child: const AdminPayments(),
      ),
      PageConfig(
        icon: const Icon(Icons.quiz),
        title: 'Quizzes',
        child: const AdminQuizzesPage(),
      ),
      PageConfig(
        icon: const Icon(Icons.reviews),
        title: 'Reviews',
        child: const AdminReviews(),
      ),
      PageConfig(
        icon: const Icon(Icons.report_sharp),
        title: 'Reports',
        child: const AdminReports(),
      ),
      PageConfig(
        icon: const Icon(Icons.settings),
        title: 'Settings',
        child: AdminSettings(onNavigate: _onItemTapped),
      ),
    ];
  }

  void _onItemTapped(int index) {
    subtitleNotifier.value = null;
    setState(() => _selectedIndex = index);
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