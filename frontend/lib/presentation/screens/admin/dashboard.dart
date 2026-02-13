import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Container(
      color: const Color(0xFFF5F5F5),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isMobile
                ? Column(
              children: const [
                MetricCard(title: "Total Users", value: "45"),
                MetricCard(title: "Heritage Sites", value: "41"),
                MetricCard(title: "Homestays", value: "28"),
                MetricCard(title: "Total Revenue", value: "Rs. 125K"),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                MetricCard(title: "Total Users", value: "45"),
                MetricCard(title: "Heritage Sites", value: "41"),
                MetricCard(title: "Homestays", value: "28"),
                MetricCard(title: "Total Revenue", value: "Rs. 125K"),
              ],
            ),

            const SizedBox(height: 32),

            //this is for section box the large box with title and child
            isMobile
                ? Column(
              children: const [
                SectionBox(
                  title: "Recent Activity",
                  child: ActivityList(),
                ),
                SizedBox(height: 16),
                SectionBox(
                  title: "Quick Stats",
                  child: QuickStatsGrid(),
                ),
              ],
            )
                : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(
                  child: SectionBox(title: "Recent Activity", child: ActivityList()),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: SectionBox(title: "Quick Stats", child: QuickStatsGrid()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  const MetricCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Container(
      width: isMobile ? double.infinity : 350,
      height: isMobile? 80:140,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

//this is for the section box paddings and all
class SectionBox extends StatelessWidget {
  final String title;
  final Widget child;
  const SectionBox({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

//this is for activity list data
class ActivityList extends StatelessWidget {
  const ActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ActivityTile(title: "New user registration", subtitle: "Saroj Karki • 2 hours ago"),
        ActivityTile(title: "New homestay added", subtitle: "Ram Host • 5 hours ago"),
        ActivityTile(title: "Booking completed", subtitle: "Anil Sharma • 1 day ago"),
      ],
    );
  }
}

class ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  const ActivityTile({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.notifications, color: Colors.blueAccent),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

//this is for the quick stats data
class QuickStatsGrid extends StatelessWidget {
  const QuickStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 50,
      runSpacing: 16,
      children: const [
        StatCard(title: "Today's Bookings", value: "12"),
        StatCard(title: "Pending Reviews", value: "8"),
        StatCard(title: "Active Hosts", value: "15"),
        StatCard(title: "Monthly Revenue", value: "Rs. 25,000"),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  const StatCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return SizedBox(
      width: isMobile ? (width / 2) : 320, // half screen width in the phone from the web
      height: 100,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  overflow: TextOverflow.ellipsis, //this is to prevent the overflow
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}