import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import '../../../data/models/Homestay.dart';
import '../../state_management/Bloc/homestays/HomestayBloc.dart';
import '../../state_management/Bloc/homestays/HomestayEvent.dart';
import '../../state_management/Bloc/homestays/HomestayState.dart';
import 'Adminhomestaydetailpage.dart';

class Homestays extends StatefulWidget {
  final ValueNotifier subtitleNotifier;
  const Homestays({super.key, required this.subtitleNotifier});

  @override
  State<Homestays> createState() => HomestaysState();
}

class HomestaysState extends State<Homestays> {
  static const _accent = Color(0xFF4F6AF5);
  static const _ink    = Color(0xFF1C1F26);
  static const _muted  = Color(0xFF6B7280);
  static const _bg     = Color(0xFFF7F8FC);

  String _search = '';
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => widget.subtitleNotifier.value = 'Manage Homestays');
    context.read<HomestayBloc>().add(const TouristLoadAllHomestays());
  }

  void _reload() => context.read<HomestayBloc>().add(const TouristLoadAllHomestays());

  List<Homestay> _filtered(List<Homestay> all) {
    var list = all;
    if (_filter == 'Active') list = list.where((h) => h.isVisible).toList();
    if (_filter == 'Paused') list = list.where((h) => !h.isVisible).toList();
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((h) =>
        h.name.toLowerCase().contains(q) ||
        h.location.toLowerCase().contains(q) ||
        (h.nearCulturalSite?.name.toLowerCase().contains(q) ?? false)
      ).toList();
    }
    return list;
  }

  void _pushDetail(Homestay h) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => AdminHomestayDetailPage(homestay: h)),
  ).then((_) => _reload());

  void _confirmToggle(Homestay h) {
    final on = h.isVisible;
    _confirm(
      icon: on ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
      iconColor: on ? _muted : Colors.green[600]!,
      title: on ? 'Pause Homestay?' : 'Activate Homestay?',
      body: on ? '"${h.name}" will be hidden from tourists.' : '"${h.name}" will become visible to tourists.',
      confirmLabel: on ? 'Pause' : 'Activate',
      confirmColor: on ? _muted : Colors.green[600]!,
      onConfirm: () => context.read<HomestayBloc>().add(AdminToggleHomestayVisibility(h.id, !on)),
    );
  }

  void _confirmDelete(Homestay h) {
    _confirm(
      icon: Icons.delete_outline_rounded,
      iconColor: Colors.red[600]!,
      title: 'Delete Homestay?',
      body: 'Permanently delete "${h.name}"? This cannot be undone.',
      confirmLabel: 'Delete',
      confirmColor: Colors.red[600]!,
      onConfirm: () => context.read<HomestayBloc>().add(AdminDeleteHomestay(h.id)),
    );
  }

  void _confirm({
    required IconData icon, required Color iconColor,
    required String title, required String body,
    required String confirmLabel, required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        icon: icon, iconColor: iconColor, title: title,
        body: body, confirmLabel: confirmLabel,
        confirmColor: confirmColor, onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = kIsWeb || MediaQuery.of(context).size.width >= 700;
    return Container(
      color: _bg,
      child: Column(children: [
        _toolbar(isWide),
        Expanded(
          child: BlocBuilder<HomestayBloc, HomestayState>(
            builder: (_, state) {
              if (state is HomestayLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is HomestayError) {
                return _ErrorView(message: state.message, onRetry: _reload);
              }
              if (state is TouristAllHomestaysLoaded) {
                final list    = _filtered(state.homestays);
                final activeN = state.homestays.where((h) => h.isVisible).length;
                final pausedN = state.homestays.where((h) => !h.isVisible).length;
                return Column(children: [
                  _statsBar(state.homestays.length, activeN, pausedN),
                  const Divider(height: 1, color: Color(0xFFE8EAF0)),
                  Expanded(
                    child: list.isEmpty
                        ? _EmptyView(filter: _filter)
                        : isWide
                            ? _WebGrid(list: list, onView: _pushDetail, onToggle: _confirmToggle, onDelete: _confirmDelete)
                            : _MobileList(list: list, onView: _pushDetail, onToggle: _confirmToggle, onDelete: _confirmDelete),
                  ),
                ]);
              }
              return const SizedBox.shrink();
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
              Text('Homestays', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: _ink)),
              const SizedBox(height: 2),
              Text('Manage all homestay listings', style: GoogleFonts.inter(fontSize: 13, color: _muted)),
            ]),
            const Spacer(),
            _filterChips(),
          ]),
          const SizedBox(height: 12),
          _searchBar(),
        ] else ...[
          _searchBar(),
          const SizedBox(height: 10),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: _filterChips()),
        ],
      ]),
    );
  }

  Widget _filterChips() {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (final label in ['All', 'Active', 'Paused']) ...[
        _FilterChip(
          label: label,
          selected: _filter == label,
          selectedColor: label == 'Active' ? Colors.green[600]! : label == 'Paused' ? _muted : _accent,
          onTap: () => setState(() => _filter = label),
        ),
        const SizedBox(width: 8),
      ],
    ]);
  }

  Widget _searchBar() {
    return SizedBox(
      height: 42,
      child: TextField(
        onChanged: (v) => setState(() => _search = v),
        style: GoogleFonts.inter(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search by name or location...',
          hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 18),
          suffixIcon: IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF9CA3AF)),
            onPressed: _reload,
          ),
          filled: true,
          fillColor: const Color(0xFFF7F8FC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE8EAF0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE8EAF0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _accent)),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _statsBar(int total, int activeN, int pausedN) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
      child: Row(children: [
        _StatPill(label: 'Total',  count: total,   color: _accent),
        const SizedBox(width: 8),
        _StatPill(label: 'Active', count: activeN, color: Colors.green[600]!),
        const SizedBox(width: 8),
        _StatPill(label: 'Paused', count: pausedN, color: _muted),
      ]),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.selectedColor, required this.onTap});

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

class _StatPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatPill({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text('$count', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(width: 5),
      Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
    ]),
  );
}

class _WebGrid extends StatelessWidget {
  final List<Homestay> list;
  final void Function(Homestay) onView, onToggle, onDelete;
  const _WebGrid({required this.list, required this.onView, required this.onToggle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.88,
      ),
      itemCount: list.length,
      itemBuilder: (_, i) => _WebCard(
        homestay: list[i],
        onView:   () => onView(list[i]),
        onToggle: () => onToggle(list[i]),
        onDelete: () => onDelete(list[i]),
      ),
    );
  }
}

class _MobileList extends StatelessWidget {
  final List<Homestay> list;
  final void Function(Homestay) onView, onToggle, onDelete;
  const _MobileList({required this.list, required this.onView, required this.onToggle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _MobileCard(
          homestay: list[i],
          onView:   () => onView(list[i]),
          onToggle: () => onToggle(list[i]),
          onDelete: () => onDelete(list[i]),
        ),
      ),
    );
  }
}

class _WebCard extends StatelessWidget {
  final Homestay homestay;
  final VoidCallback onView, onToggle, onDelete;
  const _WebCard({required this.homestay, required this.onView, required this.onToggle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final h   = homestay;
    final img = h.imageUrls.isNotEmpty ? h.imageUrls.first : null;
    final on  = h.isVisible;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EAF0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 160,
          child: Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: ProxyImage(imageUrl: img, width: double.infinity, height: 160, borderRadiusValue: 0, fit: BoxFit.cover),
            ),
            if (!on)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.4),
                    child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.pause_circle_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 5),
                      Text('Paused', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    ])),
                  ),
                ),
              ),
            Positioned(
              top: 10, left: 10,
              child: _StatusBadge(isActive: on),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(h.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1C1F26))),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 3),
              Expanded(child: Text(h.location, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)))),
            ]),
            const SizedBox(height: 6),
            Text('Rs. ${h.pricePerNight.toStringAsFixed(0)} / night',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF4F6AF5))),
            const SizedBox(height: 10),
            Row(children: [
              _ABtn(icon: Icons.remove_red_eye_outlined, color: const Color(0xFF4F6AF5), onTap: onView),
              _ABtn(icon: on ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                  color: on ? const Color(0xFF6B7280) : Colors.green[600]!, onTap: onToggle),
              _ABtn(icon: Icons.delete_outline_rounded, color: Colors.red[400]!, onTap: onDelete),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _MobileCard extends StatelessWidget {
  final Homestay homestay;
  final VoidCallback onView, onToggle, onDelete;
  const _MobileCard({required this.homestay, required this.onView, required this.onToggle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final h   = homestay;
    final img = h.imageUrls.isNotEmpty ? h.imageUrls.first : null;
    final on  = h.isVisible;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EAF0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 140,
          child: Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: ProxyImage(imageUrl: img, width: double.infinity, height: 140, borderRadiusValue: 0, thumb: true, fit: BoxFit.cover),
            ),
            if (!on)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Container(color: Colors.black.withValues(alpha: 0.45),
                    child: Center(child: Text('Paused', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700))),
                  ),
                ),
              ),
            Positioned(top: 10, left: 10, child: _StatusBadge(isActive: on)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(h.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1C1F26))),
            const SizedBox(height: 3),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 3),
              Expanded(child: Text(h.location, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)))),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              Text('${h.numberOfRooms} rooms · ${h.maxGuests} guests',
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280))),
              const Spacer(),
              Text('Rs. ${h.pricePerNight.toStringAsFixed(0)}/night',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF4F6AF5))),
            ]),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFE8EAF0)),
            const SizedBox(height: 8),
            Row(children: [
              _ABtn(icon: Icons.remove_red_eye_outlined, color: const Color(0xFF4F6AF5), onTap: onView),
              _ABtn(icon: on ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                  color: on ? const Color(0xFF6B7280) : Colors.green[600]!, onTap: onToggle),
              _ABtn(icon: Icons.delete_outline_rounded, color: Colors.red[400]!, onTap: onDelete),
              const Spacer(),
              if (h.category != null && h.category!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(6)),
                  child: Text(h.category!, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B7280))),
                ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _ABtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ABtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: 20, color: color)),
  );
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: isActive ? Colors.green[600] : const Color(0xFF6B7280),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(isActive ? 'Active' : 'Paused',
          style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
    ]),
  );
}

class _ConfirmDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title, body, confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;
  const _ConfirmDialog({required this.icon, required this.iconColor, required this.title,
      required this.body, required this.confirmLabel, required this.confirmColor, required this.onConfirm});

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: Row(children: [
      Icon(icon, color: iconColor, size: 22),
      const SizedBox(width: 10),
      Expanded(child: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: const Color(0xFF1C1F26)))),
    ]),
    content: Text(body, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280), height: 1.5)),
    actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel', style: GoogleFonts.inter(color: const Color(0xFF6B7280), fontWeight: FontWeight.w600)),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: confirmColor, elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: () { Navigator.pop(context); onConfirm(); },
        child: Text(confirmLabel, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    ],
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
        const SizedBox(height: 16),
        Text('Something went wrong', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1C1F26))),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280))),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F6AF5), elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
          label: Text('Retry', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ]),
    ),
  );
}

class _EmptyView extends StatelessWidget {
  final String filter;
  const _EmptyView({required this.filter});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.home_work_outlined, size: 52, color: Colors.grey[300]),
      const SizedBox(height: 16),
      Text(filter == 'All' ? 'No homestays found' : 'No $filter homestays',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF6B7280))),
      const SizedBox(height: 6),
      Text('No homestays match your current filter',
          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF))),
    ]),
  );
}
