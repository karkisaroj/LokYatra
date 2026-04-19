import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_state.dart';
import '../../../data/models/Site.dart';
import 'SiteAddDialog.dart';
import 'SiteDetailPage.dart';

class AdminSites extends StatefulWidget {
  const AdminSites({super.key});
  @override
  State<AdminSites> createState() => _AdminSitesState();
}

class _AdminSitesState extends State<AdminSites> {
  static const _slate      = Color(0xFF3D5A80);
  static const _terracotta = Color(0xFFCD6E4E);

  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<CulturalSite>? _lastSites; // keeps list visible during error states

  @override
  void initState() {
    super.initState();
    context.read<SitesBloc>().add(LoadSites());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addSite() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SitesBloc>(),
          child: const SiteAddPage(),
        ),
      ),
    );
    if (result == true && mounted) context.read<SitesBloc>().add(LoadSites());
  }

  Future<void> _editSite(CulturalSite site) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SitesBloc>(),
          child: SiteEditPage(site: site),
        ),
      ),
    );
    if (result == true && mounted) context.read<SitesBloc>().add(LoadSites());
  }

  Future<void> _deleteSite(int id) async {
    if (id == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invalid Site ID'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Site'),
        content: const Text('Are you sure you want to delete this site? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    context.read<SitesBloc>().add(DeleteSite(id));
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
                  hintText: 'Search by name, category, or district...',
                  hintStyle: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: GoogleFonts.dmSans(fontSize: 13),
                onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _addSite,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Site'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _terracotta,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ]),
          const SizedBox(height: 12),

          Expanded(
            child: BlocConsumer<SitesBloc, SitesState>(
              listener: (context, state) {
                if (state is SitesLoaded) {
                  // Keep a local copy so the list stays visible on error
                  _lastSites = state.sites;
                }
                if (state is SitesError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red[700],
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              },
              builder: (context, state) {
                if (state is SitesLoading && _lastSites == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Only show full-page error when there's truly no data to display
                if (state is SitesError && _lastSites == null) {
                  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<SitesBloc>().add(LoadSites()),
                      child: const Text('Retry'),
                    ),
                  ]));
                }
                // Show list from last-known data during loading/error states too
                var sites = state is SitesLoaded ? state.sites : (_lastSites ?? []);
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery;
                  sites = sites.where((s) =>
                    (s.name ?? '').toLowerCase().contains(q) ||
                    (s.category ?? '').toLowerCase().contains(q) ||
                    (s.district ?? '').toLowerCase().contains(q)
                  ).toList();
                }
                if (sites.isEmpty && state is SitesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (sites.isEmpty) {
                  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_searchQuery.isEmpty ? Icons.location_off : Icons.search_off,
                        size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(_searchQuery.isEmpty ? 'No sites available' : 'No sites match your search',
                        style: GoogleFonts.dmSans(fontSize: 15, color: Colors.grey)),
                    if (_searchQuery.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); },
                        child: const Text('Clear search'),
                      ),
                    ],
                  ]));
                }
                return isWide ? _buildWebTable(sites) : _buildMobileList(sites);
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildWebTable(List<CulturalSite> sites) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(children: [
        // Header row
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              const SizedBox(width: 72),
              const SizedBox(width: 12),
              Expanded(flex: 3, child: Text('Name',     style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey[600]))),
              Expanded(flex: 2, child: Text('Category', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey[600]))),
              Expanded(flex: 2, child: Text('District', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey[600]))),
              SizedBox(width: 120, child: Text('Actions', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey[600]))),
            ]),
          ),
        ),
        // Data rows
        Expanded(
          child: ListView.separated(
            itemCount: sites.length,
            separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, i) {
              final site     = sites[i];
              final imageUrl = getFirstImageUrl(site.imageUrls);
              final siteId   = int.tryParse(site.id.toString()) ?? 0;
              return InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SiteDetailPage(site: site))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(children: [
                    ProxyImage(imageUrl: imageUrl, width: 72, height: 56, borderRadiusValue: 8),
                    const SizedBox(width: 12),
                    Expanded(flex: 3, child: Text(
                      site.name ?? '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E)),
                    )),
                    Expanded(flex: 2, child: Text(
                      site.category ?? '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[600]),
                    )),
                    Expanded(flex: 2, child: Text(
                      site.district ?? '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[600]),
                    )),
                    SizedBox(
                      width: 120,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        _ActionBtn(icon: Icons.remove_red_eye, color: _slate,     tooltip: 'View',   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SiteDetailPage(site: site)))),
                        _ActionBtn(icon: Icons.edit,            color: _slate,     tooltip: 'Edit',   onTap: () => _editSite(site)),
                        _ActionBtn(icon: Icons.delete_rounded,  color: Colors.red, tooltip: 'Delete', onTap: () => _deleteSite(siteId)),
                      ]),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildMobileList(List<CulturalSite> sites) {
    return ListView.separated(
      itemCount: sites.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final site     = sites[index];
        final imageUrl = getFirstImageUrl(site.imageUrls);
        final siteId   = int.tryParse(site.id.toString()) ?? 0;
        final subtitle = [site.category ?? '', site.district ?? '']
            .where((v) => v.isNotEmpty).join(' • ');
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SiteDetailPage(site: site))),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(children: [
                ProxyImage(imageUrl: imageUrl, width: 60, height: 60, borderRadiusValue: 8),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(site.name ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[600])),
                ])),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  _ActionBtn(icon: Icons.edit,           color: _slate,     tooltip: 'Edit',   onTap: () => _editSite(site)),
                  _ActionBtn(icon: Icons.delete_rounded, color: Colors.red, tooltip: 'Delete', onTap: () => _deleteSite(siteId)),
                ]),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.tooltip, required this.onTap});
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    icon: Icon(icon, size: 18, color: color),
    onPressed: onTap,
  );
}