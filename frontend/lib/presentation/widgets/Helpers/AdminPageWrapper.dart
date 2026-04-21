import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../state_management/Bloc/auth/auth_bloc.dart';
import '../../state_management/Bloc/auth/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'LazyIndexedStack.dart';

class PageConfig {
  final String title;
  final String? subtitle;
  final Widget icon; // Changed to Widget to support more icon types
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
    final page = pages[selectedIndex];
    final isWide = MediaQuery.of(context).size.width >= 1100; // Increased breakpoint for better layout

    final contentStack = LazyIndexedStack(
      index: selectedIndex,
      children: pages.map((p) => p.child).toList(),
    );

    if (isWide) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFF3F4F7),
        body: Row(children: [
          _Sidebar(pages: pages, selectedIndex: selectedIndex, onTap: onItemTapped),
          Expanded(
            child: Column(children: [
              _TopBar(page: page, subtitleNotifier: subtitleNotifier),
              Expanded(
                child: FadeInUp(
                  key: ValueKey(selectedIndex),
                  duration: const Duration(milliseconds: 300),
                  child: contentStack,
                ),
              ),
            ]),
          ),
        ]),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF3F4F7),
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
      elevation: 0,
      centerTitle: false,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: Color(0xFF1E1E2D), size: 24),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: ValueListenableBuilder<String?>(
        valueListenable: subtitleNotifier,
        builder: (_, subtitle, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(page.title,
                  style: GoogleFonts.outfit(
                    fontSize: 18, 
                    fontWeight: FontWeight.w700, 
                    color: const Color(0xFF1E1E2D),
                  )),
              if (subtitle != null || page.subtitle != null)
                Text(subtitle ?? page.subtitle!,
                    style: GoogleFonts.inter(
                      fontSize: 11, 
                      color: const Color(0xFF71717A),
                    )),
            ],
          );
        },
      ),
      actions: page.actions,
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
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(children: [
        Expanded(
          child: ValueListenableBuilder<String?>(
            valueListenable: subtitleNotifier,
            builder: (_, subtitle, __) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(page.title,
                    style: GoogleFonts.outfit(
                      fontSize: 22, 
                      fontWeight: FontWeight.w700, 
                      color: const Color(0xFF1E1E2D),
                    )),
                if (subtitle != null || page.subtitle != null)
                  Text(subtitle ?? page.subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 13, 
                        color: const Color(0xFF71717A),
                        fontWeight: FontWeight.w500,
                      )),
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
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(children: [
        const SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset('assets/images/lokyatra_logo.png', height: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'LOKYATRA',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1E2D),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: pages.length,
            itemBuilder: (_, i) {
              final selected = i == selectedIndex;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SidebarItem(
                  config: pages[i],
                  isSelected: selected,
                  onTap: () => onTap(i),
                ),
              );
            },
          ),
        ),
        const Divider(color: Color(0xFFE5E7EB)),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _SidebarItem(
            config: PageConfig(
              title: 'Logout',
              icon: const Icon(Icons.logout_rounded),
              child: const SizedBox(),
            ),
            isSelected: false,
            onTap: () => context.read<AuthBloc>().add(LogoutButtonClicked()),
            isDanger: true,
          ),
        ),
        const SizedBox(height: 12),
      ]),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final PageConfig config;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDanger;

  const _SidebarItem({
    required this.config,
    required this.isSelected,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected 
        ? const Color(0xFF1E1E2D) 
        : isDanger 
            ? Colors.red[600]! 
            : const Color(0xFF71717A);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: const Color(0xFFF3F4F7).withValues(alpha: 0.5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color(0xFFF3F4F7) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected 
                ? Border.all(color: const Color(0xFF1E1E2D).withValues(alpha: 0.05))
                : null,
          ),
          child: Row(children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: IconTheme(
                data: IconThemeData(
                  size: 20, 
                  color: color,
                ),
                child: config.icon,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              config.title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
                letterSpacing: 0.2,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2D),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ]
          ]),
        ),
      ),
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
      width: 280,
      child: SafeArea(
        child: Column(children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: [
              Image.asset('assets/images/lokyatra_logo.png', height: 32),
              const SizedBox(width: 12),
              Text('LokYatra', 
                  style: GoogleFonts.outfit(
                    fontSize: 20, 
                    fontWeight: FontWeight.w800, 
                    color: const Color(0xFF1E1E2D),
                  )),
            ]),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: pages.length,
              itemBuilder: (_, i) {
                final selected = i == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _SidebarItem(
                    config: pages[i],
                    isSelected: selected,
                    onTap: () {
                      Navigator.pop(context);
                      onTap(i);
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(color: Color(0xFFE5E7EB)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _SidebarItem(
              config: PageConfig(
                title: 'Logout',
                icon: const Icon(Icons.logout_rounded),
                child: const SizedBox(),
              ),
              isSelected: false,
              onTap: () => context.read<AuthBloc>().add(LogoutButtonClicked()),
              isDanger: true,
            ),
          ),
        ]),
      ),
    );
  }
}

