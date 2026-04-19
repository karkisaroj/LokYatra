import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state_management/Bloc/auth/auth_bloc.dart';
import '../../state_management/Bloc/auth/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final page     = pages[selectedIndex];
    final isWide   = MediaQuery.of(context).size.width >= 900;

    final contentStack = IndexedStack(
      index: selectedIndex,
      children: pages.map((p) => p.child).toList(),
    );

    if (isWide) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        body: Row(children: [
          _Sidebar(pages: pages, selectedIndex: selectedIndex, onTap: onItemTapped),
          Expanded(
            child: Column(children: [
              _TopBar(page: page, subtitleNotifier: subtitleNotifier),
              Expanded(child: contentStack),
            ]),
          ),
        ]),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: _TopBar(page: page, subtitleNotifier: subtitleNotifier),
      ),
      drawer: _DrawerNav(pages: pages, selectedIndex: selectedIndex, onTap: onItemTapped),
      body: contentStack,
    );
  }
}

class _TopBar extends StatelessWidget {
  final PageConfig page;
  final ValueNotifier<String?> subtitleNotifier;
  const _TopBar({required this.page, required this.subtitleNotifier});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE8EAF0))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: [
        if (isMobile)
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF1C1F26)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ValueListenableBuilder<String?>(
          valueListenable: subtitleNotifier,
          builder: (_, subtitle, __) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(page.title,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1C1F26))),
              if ((subtitle ?? page.subtitle) != null)
                Text(subtitle ?? page.subtitle!,
                    style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B7280))),
            ],
          ),
        ),
        const Spacer(),
        if (page.actions != null) ...page.actions!,
      ]),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final List<PageConfig> pages;
  final int selectedIndex;
  final Function(int) onTap;
  const _Sidebar({required this.pages, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFF1C1F26),
      child: Column(children: [
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(color: const Color(0xFF4F6AF5), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.travel_explore_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text('LokYatra', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          ]),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Admin Panel', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B7280))),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: pages.length,
            itemBuilder: (_, i) {
              final selected = i == selectedIndex;
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: InkWell(
                  onTap: () => onTap(i),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF4F6AF5) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: [
                      IconTheme(
                        data: IconThemeData(size: 18, color: selected ? Colors.white : const Color(0xFF9CA3AF)),
                        child: pages[i].icon,
                      ),
                      const SizedBox(width: 10),
                      Text(pages[i].title,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                            color: selected ? Colors.white : const Color(0xFF9CA3AF),
                          )),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(color: Color(0xFF2D3139), height: 1),
        Padding(
          padding: const EdgeInsets.all(12),
          child: InkWell(
            onTap: () => context.read<AuthBloc>().add(LogoutButtonClicked()),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(children: [
                const Icon(Icons.logout_rounded, size: 18, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 10),
                Text('Logout', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF))),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ]),
    );
  }
}

class _DrawerNav extends StatelessWidget {
  final List<PageConfig> pages;
  final int selectedIndex;
  final Function(int) onTap;
  const _DrawerNav({required this.pages, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1C1F26),
      width: 240,
      child: SafeArea(
        child: Column(children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(color: const Color(0xFF4F6AF5), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.travel_explore_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text('LokYatra', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
            ]),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: pages.length,
              itemBuilder: (_, i) {
                final selected = i == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      onTap(i);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF4F6AF5) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(children: [
                        IconTheme(
                          data: IconThemeData(size: 18, color: selected ? Colors.white : const Color(0xFF9CA3AF)),
                          child: pages[i].icon,
                        ),
                        const SizedBox(width: 10),
                        Text(pages[i].title,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              color: selected ? Colors.white : const Color(0xFF9CA3AF),
                            )),
                      ]),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Color(0xFF2D3139), height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: InkWell(
              onTap: () => context.read<AuthBloc>().add(LogoutButtonClicked()),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(children: [
                  const Icon(Icons.logout_rounded, size: 18, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 10),
                  Text('Logout', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF))),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
