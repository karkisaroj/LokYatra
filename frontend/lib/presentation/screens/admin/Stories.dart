import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/stories/story_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/stories/story_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/stories/story_state.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_state.dart';
import 'StoryAddDialog.dart';
import 'StoryDetailPage.dart';

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

  void _onSiteChanged(int? id) {
    setState(() => _selectedSiteId = id);
    context.read<StoryBloc>().add(LoadStories(siteId: id));
  }

  Future<void> _openAddStory() async {
    if (_selectedSiteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a site first')));
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => StoryAddDialog(siteId: _selectedSiteId!),
    );
    if (ok == true) {
      context.read<StoryBloc>().add(LoadStories(siteId: _selectedSiteId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: BlocBuilder<SitesBloc, SitesState>(
                    builder: (context, state) {
                      if (state is SitesLoading) return const SizedBox(height: 56, child: Center(child: CircularProgressIndicator()));
                      if (state is SitesError) return Text(state.message);
                      if (state is SitesLoaded) {
                        final sites = state.sites;
                        return DropdownButtonFormField<int>(
                          value: _selectedSiteId,
                          items: sites.map((s) => DropdownMenuItem<int>(
                            value: s['id'] as int,
                            child: Text((s['name'] ?? '').toString(), overflow: TextOverflow.ellipsis),
                          )).toList(),
                          onChanged: _onSiteChanged,
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Related Cultural Site', border: OutlineInputBorder()),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(onPressed: _openAddStory, icon: const Icon(Icons.add), label: const Text('Add Story')),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<StoryBloc, StoryState>(
                builder: (context, state) {
                  if (state is StoryLoading) return const Center(child: CircularProgressIndicator());
                  if (state is StoryError) return Center(child: Text(state.message));
                  if (state is StoriesLoaded) {
                    final stories = state.stories;
                    if (stories.isEmpty) return const Center(child: Text('No stories yet'));

                    if (isWide) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Image')),
                            DataColumn(label: Text('Title')),
                            DataColumn(label: Text('Read Time')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: stories.map<DataRow>((st) {
                            final imgs = (st['imageUrls'] as List?)?.cast<String>() ?? const [];
                            final cover = imgs.isNotEmpty ? imgs.first : null;
                            return DataRow(cells: [
                              DataCell(
                                cover != null
                                    ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(cover, width: 56, height: 56, fit: BoxFit.cover))
                                    : const Icon(Icons.image),
                              ),
                              DataCell(Text((st['title'] ?? '').toString())),
                              DataCell(Text('${st['estimatedReadTimeMinutes'] ?? 0} min')),
                              DataCell(IconButton(
                                tooltip: 'View',
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StoryDetailPage(story: st))),
                                icon: const Icon(Icons.remove_red_eye),
                              )),
                            ]);
                          }).toList(),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: stories.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final st = stories[i] as Map<String, dynamic>;
                        final imgs = (st['imageUrls'] as List?)?.cast<String>() ?? const [];
                        final cover = imgs.isNotEmpty ? imgs.first : null;
                        return Card(
                          elevation: 0.5,
                          child: ListTile(
                            leading: cover != null
                                ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(cover, width: 56, height: 56, fit: BoxFit.cover))
                                : const Icon(Icons.image),
                            title: Text((st['title'] ?? '').toString(), maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text('${st['estimatedReadTimeMinutes'] ?? 0} min'),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StoryDetailPage(story: st))),
                          ),
                        );
                      },
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