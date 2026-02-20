import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import 'package:lokyatra_frontend/data/datasources/Stories_remote_datasource.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/stories/story_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/stories/story_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/stories/story_state.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_state.dart';
import 'StoryAddDialog.dart';
import 'StoryDetailPage.dart';
import 'StoryEditDialog.dart';

class Stories extends StatefulWidget {
  const Stories({super.key});

  @override
  State<Stories> createState() => _StoriesState();
}

class _StoriesState extends State<Stories> {
  static const _dark   = Color(0xFF1A1A2E);
  static const _accent = Color(0xFF3D5A80);

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
    if (_selectedSiteId == null) {
      _snack('Select a cultural site first');
      return;
    }
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => StoryAddDialog(siteId: _selectedSiteId!),
    );
    if (result == true) {
      context.read<StoryBloc>().add(LoadStories(siteId: _selectedSiteId));
    }
  }

  Future<void> _editStory(Map<String, dynamic> story) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => StoryEditDialog(story: story),
    );
    if (result == true) {
      context.read<StoryBloc>().add(LoadStories(siteId: _selectedSiteId));
    }
  }

  Future<void> _deleteStory(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r)),
        title: Text('Delete Story',
            style: GoogleFonts.playfairDisplay(
                fontSize: 16.sp, fontWeight: FontWeight.bold)),
        content: Text(
            'This action cannot be undone. Are you sure?',
            style: GoogleFonts.dmSans(fontSize: 13.sp)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel',
                  style: GoogleFonts.dmSans(color: Colors.grey[600]))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700], elevation: 0),
            child: Text('Delete',
                style: GoogleFonts.dmSans(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final res = await StoriesRemoteDatasource().deleteStory(id);
      if (res.statusCode == 200 || res.statusCode == 204) {
        context.read<StoryBloc>().add(LoadStories(siteId: _selectedSiteId));
        _snack('Story deleted', success: true);
      } else {
        _snack('Delete failed: ${res.statusCode}');
      }
    } catch (e) {
      _snack('Error: $e');
    }
  }

  void _snack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.dmSans()),
      backgroundColor: success ? Colors.green[700] : Colors.red[700],
      behavior: SnackBarBehavior.floating,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      margin: EdgeInsets.all(12.w),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Toolbar ────────────────────────────────────────────
            Wrap(
              spacing: 12.w,
              runSpacing: 10.h,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Site dropdown
                SizedBox(
                  width: isWide ? 300.w : double.infinity,
                  child: BlocBuilder<SitesBloc, SitesState>(
                    builder: (context, state) {
                      if (state is SitesLoading) {
                        return SizedBox(
                            height: 48.h,
                            child: const Center(
                                child: CircularProgressIndicator()));
                      }
                      if (state is SitesLoaded) {
                        return DropdownButtonFormField<int>(
                          value: _selectedSiteId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Cultural Site',
                            labelStyle: GoogleFonts.dmSans(
                                fontSize: 13.sp, color: Colors.grey[600]),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade300)),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 10.h),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: [
                            DropdownMenuItem<int>(
                              value: null,
                              child: Text('All Sites',
                                  style:
                                  GoogleFonts.dmSans(fontSize: 13.sp)),
                            ),
                            ...state.sites.map((site) => DropdownMenuItem<int>(
                              value: site['id'] as int,
                              child: Text(
                                  (site['name'] ?? '').toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 13.sp)),
                            )),
                          ],
                          onChanged: _onSiteChanged,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),

                // Search bar
                SizedBox(
                  width: isWide ? 240.w : double.infinity,
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    style: GoogleFonts.dmSans(fontSize: 13.sp),
                    decoration: InputDecoration(
                      hintText: 'Search stories...',
                      hintStyle: GoogleFonts.dmSans(
                          fontSize: 13.sp, color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search,
                          size: 18.sp, color: Colors.grey[500]),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide:
                          BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide:
                          BorderSide(color: Colors.grey.shade300)),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 10.h),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),

                // Add button
                SizedBox(
                  height: 44.h,
                  child: ElevatedButton.icon(
                    onPressed: _addStory,
                    icon: Icon(Icons.add, size: 18.sp),
                    label: Text('Add Story',
                        style: GoogleFonts.dmSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 10.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // ── Story list / table ──────────────────────────────────
            Expanded(
              child: BlocBuilder<StoryBloc, StoryState>(
                builder: (context, state) {
                  if (state is StoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is StoryError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 40.sp, color: Colors.grey[400]),
                          SizedBox(height: 8.h),
                          Text(state.message,
                              style: GoogleFonts.dmSans(
                                  fontSize: 13.sp, color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  if (state is StoriesLoaded) {
                    final filtered = state.stories.where((s) {
                      final title =
                      (s['title'] ?? '').toString().toLowerCase();
                      return _search.isEmpty ||
                          title.contains(_search.toLowerCase());
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu_book_outlined,
                                size: 48.sp, color: Colors.grey[300]),
                            SizedBox(height: 12.h),
                            Text('No stories found',
                                style: GoogleFonts.playfairDisplay(
                                    fontSize: 18.sp,
                                    color: Colors.grey[500])),
                            SizedBox(height: 6.h),
                            Text('Add a story to get started',
                                style: GoogleFonts.dmSans(
                                    fontSize: 13.sp,
                                    color: Colors.grey[400])),
                          ],
                        ),
                      );
                    }

                    return isWide
                        ? _WideTable(
                      stories: filtered,
                      onView: (s) => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  StoryDetailPage(story: s))),
                      onEdit: _editStory,
                      onDelete: (s) =>
                          _deleteStory(s['id'] as int),
                    )
                        : _MobileList(
                      stories: filtered,
                      onView: (s) => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  StoryDetailPage(story: s))),
                      onEdit: _editStory,
                      onDelete: (s) =>
                          _deleteStory(s['id'] as int),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Wide screen table ─────────────────────────────────────────────────────────

class _WideTable extends StatelessWidget {
  final List<dynamic> stories;
  final void Function(Map<String, dynamic>) onView;
  final void Function(Map<String, dynamic>) onEdit;
  final void Function(Map<String, dynamic>) onDelete;

  const _WideTable({
    required this.stories,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r)),
              border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                SizedBox(width: 60.w),
                SizedBox(width: 12.w),
                Expanded(
                    flex: 3,
                    child: _headerCell('Title')),
                SizedBox(width: 120.w, child: _headerCell('Type')),
                SizedBox(width: 100.w, child: _headerCell('Read Time')),
                SizedBox(width: 120.w, child: _headerCell('Actions')),
              ],
            ),
          ),

          // Table rows
          Expanded(
            child: ListView.separated(
              itemCount: stories.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (context, i) {
                final s = stories[i] as Map<String, dynamic>;
                final imageUrl = getFirstImageUrl(s['imageUrls']);
                return Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 10.h),
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6.r),
                        child: ProxyImage(
                          imageUrl: imageUrl,
                          width: 60.w,
                          height: 60.h,
                          borderRadiusValue: 6,
                          thumb: true,
                        ),
                      ),
                      SizedBox(width: 12.w),

                      // Title
                      Expanded(
                        flex: 3,
                        child: Text(
                          (s['title'] ?? '').toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600),
                        ),
                      ),

                      // Type
                      SizedBox(
                        width: 120.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            (s['storyType'] ?? '—').toString(),
                            style: GoogleFonts.dmSans(
                                fontSize: 11.sp,
                                color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      // Read time
                      SizedBox(
                        width: 100.w,
                        child: Text(
                          '${s['estimatedReadTimeMinutes'] ?? 0} min',
                          style: GoogleFonts.dmSans(
                              fontSize: 12.sp, color: Colors.grey[600]),
                        ),
                      ),

                      // Actions
                      SizedBox(
                        width: 120.w,
                        child: Row(
                          children: [
                            _ActionIcon(
                              icon: Icons.remove_red_eye_outlined,
                              tooltip: 'View',
                              onTap: () => onView(s),
                            ),
                            _ActionIcon(
                              icon: Icons.edit_outlined,
                              tooltip: 'Edit',
                              onTap: () => onEdit(s),
                            ),
                            _ActionIcon(
                              icon: Icons.delete_outline,
                              tooltip: 'Delete',
                              color: Colors.red[400]!,
                              onTap: () => onDelete(s),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String label) => Text(label,
      style: GoogleFonts.dmSans(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: Colors.grey[600]));
}

// ── Mobile list ───────────────────────────────────────────────────────────────

class _MobileList extends StatelessWidget {
  final List<dynamic> stories;
  final void Function(Map<String, dynamic>) onView;
  final void Function(Map<String, dynamic>) onEdit;
  final void Function(Map<String, dynamic>) onDelete;

  const _MobileList({
    required this.stories,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: stories.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, i) {
        final s = stories[i] as Map<String, dynamic>;
        final imageUrl = getFirstImageUrl(s['imageUrls']);
        final title = (s['title'] ?? '').toString();
        final type = (s['storyType'] ?? '').toString();
        final readTime = s['estimatedReadTimeMinutes'] ?? 0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: () => onView(s),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: ProxyImage(
                      imageUrl: imageUrl,
                      width: 64.w,
                      height: 64.h,
                      borderRadiusValue: 8,
                      thumb: true,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600)),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            if (type.isNotEmpty) ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 7.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius:
                                  BorderRadius.circular(20.r),
                                ),
                                child: Text(type,
                                    style: GoogleFonts.dmSans(
                                        fontSize: 10.sp,
                                        color: Colors.grey[600])),
                              ),
                              SizedBox(width: 6.w),
                            ],
                            Text('$readTime min read',
                                style: GoogleFonts.dmSans(
                                    fontSize: 11.sp,
                                    color: Colors.grey[500])),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  Column(
                    children: [
                      _ActionIcon(
                          icon: Icons.edit_outlined,
                          tooltip: 'Edit',
                          onTap: () => onEdit(s)),
                      _ActionIcon(
                          icon: Icons.delete_outline,
                          tooltip: 'Delete',
                          color: Colors.red[400]!,
                          onTap: () => onDelete(s)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Action icon button ────────────────────────────────────────────────────────

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color color;

  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color = const Color(0xFF555555),
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(6.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Icon(icon, size: 18.sp, color: color),
        ),
      ),
    );
  }
}