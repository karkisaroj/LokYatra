import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import 'package:lokyatra_frontend/data/datasources/sites_remote_datasource.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_state.dart';
import 'SiteAddDialog.dart';
import 'SiteDetailPage.dart';
import 'SiteEditDialog.dart';

class Sites extends StatefulWidget {
  const Sites({super.key});
  @override
  State<Sites> createState() => _SitesState();
}

class _SitesState extends State<Sites> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

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

  // ─── Actions ───

  Future<void> _addSite() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SiteAddDialog(),
    );
    if (result == true) {
      context.read<SitesBloc>().add(LoadSites());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Site added')));
    }
  }

  Future<void> _editSite(Map<String, dynamic> site) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SiteEditDialog(site: site),
    );
    if (result == true) {
      context.read<SitesBloc>().add(LoadSites());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Site updated')));
    }
  }

  Future<void> _deleteSite(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Site'),
        content: const Text('Are you sure you want to delete this site?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await SitesRemoteDatasource().deleteSite(id);
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
        context.read<SitesBloc>().add(LoadSites());
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
            // Search bar and Add button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search sites...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim().toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _addSite,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Site'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Sites list
            Expanded(
              child: BlocBuilder<SitesBloc, SitesState>(
                builder: (context, state) {
                  if (state is SitesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is SitesError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is SitesLoaded) {
                    // Filter sites by search query
                    var sites = state.sites;
                    if (_searchQuery.isNotEmpty) {
                      sites = sites.where((site) {
                        String name = (site['name'] ?? '').toString().toLowerCase();
                        String category = (site['category'] ?? '').toString().toLowerCase();
                        String district = (site['district'] ?? '').toString().toLowerCase();
                        return name.contains(_searchQuery) ||
                            category.contains(_searchQuery) ||
                            district.contains(_searchQuery);
                      }).toList();
                    }

                    if (sites.isEmpty) {
                      return const Center(child: Text('No sites'));
                    }

                    if (isWideScreen) {
                      return _buildWideTable(sites);
                    }
                    return _buildMobileList(sites);
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

  Widget _buildWideTable(List<dynamic> sites) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 32,
        dataRowMinHeight: 80,
        dataRowMaxHeight: 88,
        columns: const [
          DataColumn(label: Text('Image')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('District')),
          DataColumn(label: Text('Actions')),
        ],
        rows: sites.map<DataRow>((site) {
          String? imageUrl = getFirstImageUrl(site['imageUrls']);

          return DataRow(cells: [
            DataCell(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ProxyImage(imageUrl: imageUrl, width: 64, height: 64),
              ),
            ),
            DataCell(SizedBox(width: 240, child: Text((site['name'] ?? '').toString(), maxLines: 1, overflow: TextOverflow.ellipsis))),
            DataCell(SizedBox(width: 160, child: Text((site['category'] ?? '').toString(), maxLines: 1, overflow: TextOverflow.ellipsis))),
            DataCell(SizedBox(width: 160, child: Text((site['district'] ?? '').toString(), maxLines: 1, overflow: TextOverflow.ellipsis))),
            DataCell(
              Row(children: [
                IconButton(tooltip: 'View', icon: const Icon(Icons.remove_red_eye), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SiteDetailPage(site: site)))),
                IconButton(tooltip: 'Edit', icon: const Icon(Icons.edit), onPressed: () => _editSite(site)),
                IconButton(tooltip: 'Delete', icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteSite(site['id'] as int)),
              ]),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  // ─── Mobile list ───

  Widget _buildMobileList(List<dynamic> sites) {
    return ListView.separated(
      itemCount: sites.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        Map<String, dynamic> site = sites[index] as Map<String, dynamic>;
        String? imageUrl = getFirstImageUrl(site['imageUrls']);

        String name = (site['name'] ?? '').toString();
        String subtitle = [site['category'], site['district']]
            .where((value) => (value ?? '').toString().isNotEmpty)
            .join(' • ');

        return Card(
          elevation: 0.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SiteDetailPage(site: site))),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  // Image
                  ProxyImage(imageUrl: imageUrl, width: 60, height: 60),
                  const SizedBox(width: 12),

                  // Name and category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                  ),

                  // Edit and Delete buttons
                  IconButton(tooltip: 'Edit', icon: const Icon(Icons.edit, size: 20), onPressed: () => _editSite(site)),
                  IconButton(tooltip: 'Delete', icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => _deleteSite(site['id'] as int)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}