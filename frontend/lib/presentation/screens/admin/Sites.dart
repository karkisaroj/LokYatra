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
  static const _accent = Color(0xFF4F6AF5);
  static const _ink    = Color(0xFF1C1F26);
  static const _muted  = Color(0xFF6B7280);
  static const _bg     = Color(0xFFF7F8FC);

  final _searchCtrl = TextEditingController();
  String _search    = '';
  String _filter    = 'All';
  List<CulturalSite>? _lastSites;

  @override
  void initState() {
    super.initState();
    context.read<SitesBloc>().add(LoadSites());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _addSite() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(value: context.read<SitesBloc>(), child: const SiteAddPage()),
      ),
    );
    if (result == true && mounted) context.read<SitesBloc>().add(LoadSites());
  }

  Future<void> _editSite(CulturalSite site) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(value: context.read<SitesBloc>(), child: SiteEditPage(site: site)),
      ),
    );
    if (result == true && mounted) context.read<SitesBloc>().add(LoadSites());
  }

  Future<void> _deleteSite(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(children: [
          Icon(Icons.delete_outline_rounded, color: Colors.red[600], size: 22),
          const SizedBox(width: 8),
          Text('Delete Site?', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
        ]),
        content: Text('This action cannot be undone.', style: GoogleFonts.inter(fontSize: 13, color: _muted)),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: _muted, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600], elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text('Delete', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    context.read<SitesBloc>().add(DeleteSite(id));
  }

  List<CulturalSite> _applyFilter(List<CulturalSite> sites) {
    var list = sites;
    if (_filter == 'UNESCO') list = list.where((s) => s.isUNESCO == true).toList();
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((s) =>
        (s.name ?? '').toLowerCase().contains(q) ||
        (s.category ?? '').toLowerCase().contains(q) ||
        (s.district ?? '').toLowerCase().contains(q)
      ).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;
    return Container(
      color: _bg,
      child: Column(children: [
        _toolbar(isWide),
        Expanded(
          child: BlocConsumer<SitesBloc, SitesState>(
            listener: (_, state) {
              if (state is SitesLoaded) _lastSites = state.sites;
              if (state is SitesError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red[700],
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            builder: (_, state) {
              if (state is SitesLoading && _lastSites == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is SitesError && _lastSites == null) {
                return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Error: ${state.message}', style: GoogleFonts.inter(color: _muted)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<SitesBloc>().add(LoadSites()),
                    child: const Text('Retry'),
                  ),
                ]));
              }
              final raw   = state is SitesLoaded ? state.sites : (_lastSites ?? []);
              final sites = _applyFilter(raw);
              if (sites.isEmpty) {
                return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_search.isEmpty ? Icons.location_off : Icons.search_off, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(_search.isEmpty ? 'No sites found' : 'No sites match your search',
                      style: GoogleFonts.inter(fontSize: 15, color: _muted)),
                  if (_search.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () { _searchCtrl.clear(); setState(() => _search = ''); },
                      child: const Text('Clear search'),
                    ),
                  ],
                ]));
              }
              return Padding(
                padding: const EdgeInsets.all(16),
                child: isWide ? _webTable(sites) : _mobileList(sites),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _toolbar(bool isWide) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(isWide ? 24 : 16, 16, isWide ? 24 : 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (isWide) ...[
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Heritage Sites', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: _ink)),
              const SizedBox(height: 2),
              Text('Manage cultural heritage sites', style: GoogleFonts.inter(fontSize: 13, color: _muted)),
            ]),
            const Spacer(),
            _filterChips(),
            const SizedBox(width: 16),
            _addBtn(),
          ]),
          const SizedBox(height: 12),
          _searchBar(),
        ] else ...[
          Row(children: [
            Expanded(child: _searchBar()),
            const SizedBox(width: 8),
            _addBtn(),
          ]),
          const SizedBox(height: 10),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: _filterChips()),
        ],
      ]),
    );
  }

  Widget _filterChips() {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      _Chip(
        label: 'All',
        selected: _filter == 'All',
        selectedColor: _accent,
        onTap: () => setState(() => _filter = 'All'),
      ),
      const SizedBox(width: 8),
      _Chip(
        label: 'UNESCO',
        selected: _filter == 'UNESCO',
        selectedColor: const Color(0xFF059669),
        onTap: () => setState(() => _filter = 'UNESCO'),
      ),
    ]);
  }

  Widget _searchBar() {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _search = v.trim().toLowerCase()),
        style: GoogleFonts.inter(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search by name, category or district...',
          hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF)),
          prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF9CA3AF)),
          filled: true,
          fillColor: _bg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE8EAF0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE8EAF0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _accent)),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _addBtn() {
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: _addSite,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add Site'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    );
  }

  Widget _webTable(List<CulturalSite> sites) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EAF0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(children: [
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF9FAFB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            border: Border(bottom: BorderSide(color: Color(0xFFE8EAF0))),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            const SizedBox(width: 72),
            const SizedBox(width: 12),
            Expanded(flex: 3, child: Text('Name',     style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _muted))),
            Expanded(flex: 2, child: Text('Category', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _muted))),
            Expanded(flex: 2, child: Text('District', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _muted))),
            const SizedBox(width: 110, child: Text('Actions', textAlign: TextAlign.center)),
          ]),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: sites.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
            itemBuilder: (ctx, i) {
              final site  = sites[i];
              final img   = getFirstImageUrl(site.imageUrls);
              final siteId = int.tryParse(site.id.toString()) ?? 0;
              return InkWell(
                onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => SiteDetailPage(site: site))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(children: [
                    ProxyImage(imageUrl: img, width: 72, height: 52, borderRadiusValue: 8, thumb: true),
                    const SizedBox(width: 12),
                    Expanded(flex: 3, child: Row(children: [
                      Flexible(child: Text(site.name ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _ink))),
                      if (site.isUNESCO == true) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(4)),
                          child: Text('UNESCO', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: const Color(0xFF059669))),
                        ),
                      ],
                    ])),
                    Expanded(flex: 2, child: Text(site.category ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 13, color: _muted))),
                    Expanded(flex: 2, child: Text(site.district ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 13, color: _muted))),
                    SizedBox(
                      width: 110,
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        _IBtn(icon: Icons.remove_red_eye_outlined, color: _accent, tooltip: 'View',
                            onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => SiteDetailPage(site: site)))),
                        _IBtn(icon: Icons.edit_outlined, color: _muted, tooltip: 'Edit', onTap: () => _editSite(site)),
                        _IBtn(icon: Icons.delete_outline_rounded, color: Colors.red[400]!, tooltip: 'Delete', onTap: () => _deleteSite(siteId)),
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

  Widget _mobileList(List<CulturalSite> sites) {
    return ListView.separated(
      itemCount: sites.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final site    = sites[i];
        final img     = getFirstImageUrl(site.imageUrls);
        final siteId  = int.tryParse(site.id.toString()) ?? 0;
        final subtitle = [site.category ?? '', site.district ?? ''].where((v) => v.isNotEmpty).join(' · ');
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8EAF0)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => SiteDetailPage(site: site))),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                ProxyImage(imageUrl: img, width: 60, height: 60, borderRadiusValue: 8, thumb: true),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Flexible(child: Text(site.name ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _ink))),
                    if (site.isUNESCO == true) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(4)),
                        child: Text('UNESCO', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: const Color(0xFF059669))),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 3),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 12, color: _muted)),
                ])),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  _IBtn(icon: Icons.edit_outlined,          color: _muted,         tooltip: 'Edit',   onTap: () => _editSite(site)),
                  _IBtn(icon: Icons.delete_outline_rounded, color: Colors.red[400]!, tooltip: 'Delete', onTap: () => _deleteSite(siteId)),
                ]),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.selectedColor, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? selectedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? selectedColor : const Color(0xFFD1D5DB)),
      ),
      child: Text(label, style: GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: selected ? Colors.white : const Color(0xFF6B7280),
      )),
    ),
  );
}

class _IBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  const _IBtn({required this.icon, required this.color, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: 18, color: color)),
    ),
  );
}
