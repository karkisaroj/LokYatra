import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  int? _selectedSiteId;

  @override
  void initState() {
    super.initState();
    context.read<SitesBloc>().add(LoadSites());
    context.read<StoryBloc>().add(LoadStories());
  }

  // ─── Actions ───

  void _onSiteChanged(int? siteId) {
    setState(() => _selectedSiteId = siteId);
    context.read<StoryBloc>().add(LoadStories(siteId: siteId));
  }

  Future<void> _addStory() async {
    if (_selectedSiteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a site first')));
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Story updated')));
    }
  }

  Future<void> _deleteStory(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Story'),
        content: const Text('Are you sure you want to delete this story?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await StoriesRemoteDatasource().deleteStory(id);
      if (response.statusCode == 200 || response.statusCode == 204) {
        context.read<StoryBloc>().add(LoadStories(siteId: _selectedSiteId));
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: ${response.statusCode}')));
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Network error: $error')));
    }
  }

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 1000;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Site dropdown and Add button
            Row(
              children: [
                Expanded(
                  child: BlocBuilder<SitesBloc, SitesState>(
                    builder: (context, state) {
                      if (state is SitesLoading) {
                        return const SizedBox(height: 56, child: Center(child: CircularProgressIndicator()));
                      }
                      if (state is SitesError) {
                        return Text(state.message);
                      }
                      if (state is SitesLoaded) {
                        return DropdownButtonFormField<int>(
                          value: _selectedSiteId,
                          items: state.sites.map((site) {
                            return DropdownMenuItem<int>(
                              value: site['id'] as int,
                              child: Text((site['name'] ?? '').toString(), overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: _onSiteChanged,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Related Cultural Site',
                            border: OutlineInputBorder(),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _addStory,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Story'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Stories list
            Expanded(
              child: BlocBuilder<StoryBloc, StoryState>(
                builder: (context, state) {
                  if (state is StoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is StoryError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is StoriesLoaded) {
                    List<dynamic> stories = state.stories;
                    if (stories.isEmpty) {
                      return const Center(child: Text('No stories yet'));
                    }
                    if (isWideScreen) {
                      return _buildWideTable(stories);
                    }
                    return _buildMobileList(stories);
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

  // ─── Wide screen table ───

  Widget _buildWideTable(List<dynamic> stories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 32,
        dataRowMinHeight: 80,
        dataRowMaxHeight: 88,
        columns: const [
          DataColumn(label: Text('Image')),
          DataColumn(label: Text('Title')),
          DataColumn(label: Text('Read Time')),
          DataColumn(label: Text('Actions')),
        ],
        rows: stories.map<DataRow>((story) {
          String? imageUrl = getFirstImageUrl(story['imageUrls']);

          return DataRow(cells: [
            DataCell(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ProxyImage(imageUrl: imageUrl, width: 64, height: 64),
              ),
            ),
            DataCell(SizedBox(width: 320, child: Text((story['title'] ?? '').toString(), maxLines: 1, overflow: TextOverflow.ellipsis))),
            DataCell(SizedBox(width: 120, child: Text('${story['estimatedReadTimeMinutes'] ?? 0} min'))),
            DataCell(
              Row(children: [
                IconButton(tooltip: 'View', icon: const Icon(Icons.remove_red_eye), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StoryDetailPage(story: story)))),
                IconButton(tooltip: 'Edit', icon: const Icon(Icons.edit), onPressed: () => _editStory(story)),
                IconButton(tooltip: 'Delete', icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteStory(story['id'] as int)),
              ]),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  // ─── Mobile list ───

  Widget _buildMobileList(List<dynamic> stories) {
    return ListView.separated(
      itemCount: stories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        Map<String, dynamic> story = stories[index] as Map<String, dynamic>;
        String? imageUrl = getFirstImageUrl(story['imageUrls']);
        String title = (story['title'] ?? '').toString();
        int readTime = story['estimatedReadTimeMinutes'] ?? 0;

        return Card(
          elevation: 0.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StoryDetailPage(story: story))),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  ProxyImage(imageUrl: imageUrl, width: 60, height: 60),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('$readTime min read', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  IconButton(tooltip: 'Edit', icon: const Icon(Icons.edit, size: 20), onPressed: () => _editStory(story)),
                  IconButton(tooltip: 'Delete', icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => _deleteStory(story['id'] as int)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}