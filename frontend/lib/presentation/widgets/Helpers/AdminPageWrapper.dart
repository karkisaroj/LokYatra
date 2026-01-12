import 'package:flutter/material.dart';

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
        child: ListView(
          children: [
             Column(
               crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Dashboard",
                    style: TextStyle(fontSize: 30),
                  ),
               SizedBox(height: 10,),
               Text("Welcome to LokYatra Admin Panel",style: TextStyle(fontSize: 10),)
                ],
              ),
            Divider(),
            SizedBox(height: 20,),

            for (int i = 0; i < pages.length; i++)
              ListTile(
                leading: pages[i].icon,
                title: Text(pages[i].title),
                selected: selectedIndex == i,
                onTap: () {
                  onItemTapped(i);
                  Navigator.pop(context);
                },


              ),
          ],
        ),
      ),
      body: currentPage.child,
    );
  }
}