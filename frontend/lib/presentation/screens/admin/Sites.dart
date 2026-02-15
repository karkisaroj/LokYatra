import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_state.dart';
import 'SiteAddDialog.dart';
import 'SiteDetailPage.dart';

class Sites extends StatefulWidget {
  const Sites({super.key});
  @override
  State<Sites> createState() => _SitesState();
}

class _SitesState extends State<Sites> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<SitesBloc>().add(LoadSites());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openAddSite() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SiteAddDialog(),
    );
    if (ok == true) {
      context.read<SitesBloc>().add(LoadSites());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Site added')),
        );
      }
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
                  child: TextField(
                    controller: _search,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search sites...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _openAddSite,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Site'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<SitesBloc, SitesState>(
                builder: (context, state) {
                  if (state is SitesLoading) return const Center(child: CircularProgressIndicator());
                  if (state is SitesError) return Center(child: Text(state.message));
                  if (state is SitesLoaded) {
                    var sites = state.sites;
                    if (_query.isNotEmpty) {
                      sites = sites.where((s) {
                        final name = (s['name'] ?? '').toString().toLowerCase();
                        final category = (s['category'] ?? '').toString().toLowerCase();
                        final district = (s['district'] ?? '').toString().toLowerCase();
                        return name.contains(_query) || category.contains(_query) || district.contains(_query);
                      }).toList();
                    }
                    if (sites.isEmpty) return const Center(child: Text('No sites'));

                    if (isWide) {
                      // Web-style table
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Image')),
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Category')),
                            DataColumn(label: Text('District')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: sites.map<DataRow>((s) {
                            final imgs = (s['imageUrls'] as List?)?.cast<String>() ?? const [];
                            final cover = imgs.isNotEmpty ? imgs.first : null;
                            return DataRow(cells: [
                              DataCell(
                                cover != null
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(cover, width: 56, height: 56, fit: BoxFit.cover),
                                )
                                    : const Icon(Icons.image),
                              ),
                              DataCell(Text((s['name'] ?? '').toString())),
                              DataCell(Text((s['category'] ?? '').toString())),
                              DataCell(Text((s['district'] ?? '').toString())),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    tooltip: 'View',
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => SiteDetailPage(site: s)),
                                    ),
                                    icon: const Icon(Icons.remove_red_eye),
                                  ),
                                ],
                              )),
                            ]);
                          }).toList(),
                        ),
                      );
                    }

                    // Mobile cards
                    return ListView.separated(
                      itemCount: sites.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final s = sites[i] as Map<String, dynamic>;
                        final imgs = (s['imageUrls'] as List?)?.cast<String>() ?? const [];
                        final cover = imgs.isNotEmpty ? imgs.first : null;
                        return Card(
                          elevation: 0.5,
                          child: ListTile(
                            leading: cover != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(cover, width: 56, height: 56, fit: BoxFit.cover),
                            )
                                : const Icon(Icons.image),
                            title: Text((s['name'] ?? '').toString(), maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(
                              [s['category'], s['district']].where((e) => (e ?? '').toString().isNotEmpty).join(' • '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SiteDetailPage(site: s))),
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