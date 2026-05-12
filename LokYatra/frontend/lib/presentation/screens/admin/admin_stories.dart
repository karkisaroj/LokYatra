import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import 'package:lokyatra_frontend/data/datasources/stories_remote_datasource.dart';
import 'package:lokyatra_frontend/data/models/story.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/stories/story_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/stories/story_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/stories/story_state.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_state.dart';
import 'story_add_dialog.dart';
import 'admin_story_detail.dart';
import 'story_edit_dialog.dart';

class AdminStories extends StatefulWidget {
  const AdminStories({super.key});
  @override
  State<AdminStories> createState() => _AdminStoriesState();
}

class _AdminStoriesState extends State<AdminStories> {
  static const _accent = Color(0xFF3D5A80);
  static const _bg     = Color(0xFFF4F6F9);

  int? _selectedSiteId;
  String _search = '';

  @override
  void initState() {
    super.initState();
    context.read<SitesBloc>().add(LoadSites());
    context.read<StoryBloc>().add(LoadStories());
  }

  void _onSiteChanged(int? siteId) {
    setState(() => _selectedSiteId = siteId);
    context.read<StoryBloc>().add(LoadStories(siteId: siteId));
  }

  Future<void> _addStory() async {
    if (_selectedSiteId == null) { _snack('Select a cultural site first'); return; }
    final result = await showDialog<bool>(context: context, barrierDismissible: false,
        builder: (_) => StoryAddDialog(siteId: _selectedSiteId!));
    if(!mounted)return;
    if (result == true) context.read<StoryBloc>().add(LoadStories(siteId: _selectedSiteId));
  }

  Future<void> _editStory(Story story) async {
    final result = await showDialog<bool>(context: context, barrierDismissible: false,
        builder: (_) => StoryEditDialog(story: story.toJson()));
    if(!mounted)return;
    if (result == true) context.read<StoryBloc>().add(LoadStories(siteId: _selectedSiteId));
  }

  Future<void> _deleteStory(int id) async {
    final confirmed = await showDialog<bool>(context: context, builder: (_) => _DeleteDialog());
    if (confirmed != true) return;
    try {
      final res = await StoriesRemoteDatasource().deleteStory(id);
      if (res.statusCode == 200 || res.statusCode == 204) {
        if(!mounted)return;
        context.read<StoryBloc>().add(LoadStories(siteId: _selectedSiteId));
        _snack('Story deleted', success: true);
      } else {
        _snack('Delete failed: ${res.statusCode}');
      }
    } catch (e) { _snack('Error: $e'); }
  }

  void _snack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.dmSans()),
      backgroundColor: success ? const Color(0xFF2E9E6B) : Colors.red[700],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(12),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb || MediaQuery.of(context).size.width >= 900;
    return Container(
      color: _bg,
      child: Column(children: [
        _toolbar(isWeb),
        Expanded(child: _storyList(isWeb)),
      ]),
    );
  }

  Widget _toolbar(bool isWeb) {
    return Container(
      color: Colors.white,
      padding: isWeb ? const EdgeInsets.fromLTRB(24, 16, 24, 16) : EdgeInsets.all(16.w),
      child: isWeb ? _webToolbar() : _mobileToolbar(),
    );
  }

  Widget _webToolbar() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Cultural Stories', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E))),
          Text('Manage heritage site stories', style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[500])),
        ]),
        const Spacer(),
        IconButton(
          onPressed: () => context.read<StoryBloc>().add(LoadStories(siteId: _selectedSiteId)),
          icon: Icon(Icons.refresh, color: Colors.grey[600], size: 20),
          tooltip: 'Refresh Stories',
        ),
        const SizedBox(width: 8),
        _addButton(),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _siteDropdown()),
        const SizedBox(width: 12),
        Expanded(child: _searchField()),
      ]),
    ]);
  }

  Widget _mobileToolbar() {
    return Column(children: [
      _siteDropdown(),
      SizedBox(height: 10.h),
      Row(children: [
        Expanded(child: _searchField()),
        SizedBox(width: 8.w),
        IconButton(
          onPressed: () => context.read<StoryBloc>().add(LoadStories(siteId: _selectedSiteId)),
          icon: Icon(Icons.refresh, color: Colors.grey[600], size: 20.sp),
          tooltip: 'Refresh',
        ),
        SizedBox(width: 4.w),
        _addButton(),
      ]),
    ]);
  }

  Widget _siteDropdown() {
    return BlocBuilder<SitesBloc, SitesState>(builder: (context, state) {
      if (state is SitesLoading) return SizedBox(height: 42, child: const Center(child: CircularProgressIndicator(strokeWidth: 2)));
      if (state is SitesLoaded) {
        return DropdownButtonFormField<int>(
          initialValue: _selectedSiteId,
          isExpanded: true,
          decoration: _inputDeco('Cultural Site'),
          items: [
            DropdownMenuItem<int>(value: null, child: Text('All Sites', style: GoogleFonts.dmSans(fontSize: 13))),
            ...state.sites.map((s) => DropdownMenuItem<int>(value: s.id,
                child: Text((s.name ?? '').toString(), overflow: TextOverflow.ellipsis, style: GoogleFonts.dmSans(fontSize: 13)))),
          ],
          onChanged: _onSiteChanged,
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _searchField() {
    return TextField(
      onChanged: (v) => setState(() => _search = v),
      style: GoogleFonts.dmSans(fontSize: 13),
      decoration: _inputDeco('Search stories...').copyWith(
        prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey[500]),
      ),
    );
  }

  Widget _addButton() {
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: _addStory,
        icon: const Icon(Icons.add, size: 18),
        label: Text('Add Story', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(backgroundColor: _accent, foregroundColor: Colors.white, elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      ),
    );
  }

  Widget _storyList(bool isWeb) {
    return BlocBuilder<StoryBloc, StoryState>(builder: (context, state) {
      if (state is StoryLoading) return const Center(child: CircularProgressIndicator());
      if (state is StoryError) {
        return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.error_outline, size: 40, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(state.message, style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey)),
      ]));
      }
      if (state is StoriesLoaded) {
        final filtered = state.stories.where((s) => _search.isEmpty || s.title.toLowerCase().contains(_search.toLowerCase())).toList();
        if (filtered.isEmpty) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.menu_book_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('No stories found', style: GoogleFonts.playfairDisplay(fontSize: 18, color: Colors.grey[500])),
          const SizedBox(height: 6),
          Text('Add a story to get started', style: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[400])),
        ]));
        }
        return isWeb
            ? _webTable(filtered)
            : _mobileList(filtered);
      }
      return const SizedBox.shrink();
    });
  }

  Widget _webTable(List<Story> stories) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
            child: Row(children: [
              const SizedBox(width: 64),
              const SizedBox(width: 12),
              Expanded(flex: 3, child: _th('Title')),
              const SizedBox(width: 140, child: Text('Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF666666)))),
              const SizedBox(width: 110, child: Text('Read Time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF666666)))),
              const SizedBox(width: 130, child: Text('Actions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF666666)))),
            ]),
          ),
          Expanded(child: ListView.separated(
            itemCount: stories.length,
            separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (_, i) {
              final s = stories[i];
              return Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(6),
                      child: ProxyImage(imageUrl: s.imageUrls.isNotEmpty ? s.imageUrls.first : null, width: 64, height: 52, borderRadiusValue: 6, thumb: true)),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: Text(s.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600))),
                  SizedBox(width: 140, child: _typePill(s.storyType)),
                  SizedBox(width: 110, child: Text('${s.estimatedReadTimeMinutes} min', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey[600]))),
                  SizedBox(width: 130, child: Row(children: [
                    _Action(icon: Icons.remove_red_eye_outlined, tooltip: 'View',   onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StoryDetailPage(story: s.toJson())))),
                    _Action(icon: Icons.edit_outlined,           tooltip: 'Edit',   onTap: () => _editStory(s)),
                    _Action(icon: Icons.delete_outline,          tooltip: 'Delete', color: Colors.red[400]!, onTap: () => _deleteStory(s.id)),
                  ])),
                ]),
              );
            },
          )),
        ]),
      ),
    );
  }

  Widget _mobileList(List<Story> stories) {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: stories.length,
      separatorBuilder: (_, _) => SizedBox(height: 8.h),
      itemBuilder: (_, i) {
        final s = stories[i];
        return Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey.shade200)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StoryDetailPage(story: s.toJson()))),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(children: [
                ClipRRect(borderRadius: BorderRadius.circular(8.r),
                    child: ProxyImage(imageUrl: s.imageUrls.isNotEmpty ? s.imageUrls.first : null, width: 64.w, height: 64.h, borderRadiusValue: 8, thumb: true)),
                SizedBox(width: 12.w),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.dmSans(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4.h),
                  Row(children: [
                    if (s.storyType.isNotEmpty) ...[_typePill(s.storyType), SizedBox(width: 6.w)],
                    Text('${s.estimatedReadTimeMinutes} min read', style: GoogleFonts.dmSans(fontSize: 11.sp, color: Colors.grey[500])),
                  ]),
                ])),
                Column(children: [
                  _Action(icon: Icons.edit_outlined, tooltip: 'Edit', onTap: () => _editStory(s)),
                  _Action(icon: Icons.delete_outline, tooltip: 'Delete', color: Colors.red[400]!, onTap: () => _deleteStory(s.id)),
                ]),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _typePill(String type) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
    child: Text(type, style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey[700]), overflow: TextOverflow.ellipsis),
  );

  Widget _th(String label) => Text(label, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey[600]));

  InputDecoration _inputDeco(String label) => InputDecoration(
    labelText: label,
    labelStyle: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[600]),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    filled: true, fillColor: Colors.white,
  );
}

class _DeleteDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    title: Text('Delete Story', style: GoogleFonts.playfairDisplay(fontSize: 17, fontWeight: FontWeight.bold)),
    content: Text('This action cannot be undone. Are you sure?', style: GoogleFonts.dmSans(fontSize: 13)),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: GoogleFonts.dmSans(color: Colors.grey[600]))),
      ElevatedButton(
        onPressed: () => Navigator.pop(context, true),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700], elevation: 0),
        child: Text('Delete', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    ],
  );
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color color;
  const _Action({required this.icon, required this.tooltip, required this.onTap, this.color = const Color(0xFF555555)});
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: 18, color: color)),
    ),
  );
}


