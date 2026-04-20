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
      appBar: _MobileAppBar(page: page, subtitleNotifier: subtitleNotifier),
      drawer: _DrawerNav(pages: pages, selectedIndex: selectedIndex, onTap: onItemTapped),
      body: contentStack,
    );
  }
}

class _MobileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final PageConfig page;
  final ValueNotifier<String?> subtitleNotifier;
  const _MobileAppBar({required this.page, required this.subtitleNotifier});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: Color(0xFF1C1F26), size: 22),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: ValueListenableBuilder<String?>(
        valueListenable: subtitleNotifier,
        builder: (_, subtitle, _) {
          final sub = subtitle ?? page.subtitle;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(page.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1C1F26))),
              if (sub != null)
                Text(sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B7280))),
            ],
          );
        },
      ),
      titleSpacing: 0,
      actions: page.actions,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: Color(0xFFE8EAF0)),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final PageConfig page;
  final ValueNotifier<String?> subtitleNotifier;
  const _TopBar({required this.page, required this.subtitleNotifier});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE8EAF0))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: [
        Expanded(
          child: ValueListenableBuilder<String?>(
            valueListenable: subtitleNotifier,
            builder: (_, subtitle, __) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(page.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF1C1F26))),
                if ((subtitle ?? page.subtitle) != null)
                  Text(subtitle ?? page.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B7280))),
              ],
            ),
          ),
        ),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE8EAF0))),
      ),
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
            Text('LokYatra', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF1C1F26))),
          ]),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Admin Panel', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF))),
        ),
        const SizedBox(height: 20),
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
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFEEF2FF) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      IconTheme(
                        data: IconThemeData(size: 18, color: selected ? const Color(
                            0xFFAFB2C6) : const Color(0xFF9CA3AF)),
                        child: pages[i].icon,
                      ),
                      const SizedBox(width: 10),
                      Text(pages[i].title,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                            color: selected ? const Color(0xFF8F9093) : const Color(0xFF6B7280),
                          )),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(color: Color(0xFFE8EAF0), height: 1),
        Padding(
          padding: const EdgeInsets.all(12),
          child: InkWell(
            onTap: () => context.read<AuthBloc>().add(LogoutButtonClicked()),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Row(children: [
                const Icon(Icons.logout_rounded, size: 18, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 10),
                Text('Logout', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280))),
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
      backgroundColor: Colors.white,
      width: 240,
      child: SafeArea(
        child: Column(children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(10)),
                child:  Image.asset('assets/images/lokyatra_logo.png', color: Colors.grey[500], fit: BoxFit.fill),
              ),
              const SizedBox(width: 10),
              Text('LokYatra', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF1C1F26))),
            ]),
          ),
          const SizedBox(height: 20),
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
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFFEEF2FF) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(children: [
                        IconTheme(
                          data: IconThemeData(size: 18, color: selected ? const Color(0xFF4F6AF5) : const Color(0xFF9CA3AF)),
                          child: pages[i].icon,
                        ),
                        const SizedBox(width: 10),
                        Text(pages[i].title,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                              color: selected ? const Color(0xFF4F6AF5) : const Color(0xFF6B7280),
                            )),
                      ]),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Color(0xFFE8EAF0), height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: InkWell(
              onTap: () => context.read<AuthBloc>().add(LogoutButtonClicked()),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                child: Row(children: [
                  const Icon(Icons.logout_rounded, size: 18, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 10),
                  Text('Logout', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280))),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
