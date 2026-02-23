import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
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

    if (result == true && mounted) {
      context.read<SitesBloc>().add(LoadSites());
    }
  }

  // Method to edit a site
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

    if (result == true && mounted) {
      context.read<SitesBloc>().add(LoadSites());
    }
  }

  // Method to delete a site
  Future<void> _deleteSite(int id) async {
    if (id == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Site ID'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Site'),
        content: const Text('Are you sure you want to delete this site? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Dispatch delete event
    context.read<SitesBloc>().add(DeleteSite(id));
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 1000;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search by name, category, or district...',
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCD6E4E),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Sites list
            Expanded(
              child: BlocConsumer<SitesBloc, SitesState>(
                listener: (context, state) {
                  if (state is SitesError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is SitesLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading sites...'),
                        ],
                      ),
                    );
                  }

                  if (state is SitesError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error: ${state.message}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<SitesBloc>().add(LoadSites());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is SitesLoaded) {
                  // Get the list of CulturalSite objects
                  var sites = state.sites;

                  // Apply search filtering
                  if (_searchQuery.isNotEmpty) {
                    final query = _searchQuery.toLowerCase();
                    sites = sites.where((site) {
                      final name = (site.name ?? '').toLowerCase();
                      final category = (site.category ?? '').toLowerCase();
                      final district = (site.district ?? '').toLowerCase();

                      return name.contains(query) ||
                          category.contains(query) ||
                          district.contains(query);
                    }).toList();
                  }

                    if (sites.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isEmpty ? Icons.location_off : Icons.search_off,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No sites available'
                                  : 'No sites match your search',
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            if (_searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                child: const Text('Clear search'),
                              ),
                            ],
                          ],
                        ),
                      );
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

  // Wide screen table view
  Widget _buildWideTable(List<CulturalSite> sites) {
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
          String? imageUrl = getFirstImageUrl(site.imageUrls);
          int siteId = int.tryParse(site.id.toString()) ?? 0;

          return DataRow(cells: [
            DataCell(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ProxyImage(
                  imageUrl: imageUrl,
                  width: 64,
                  height: 64,
                  borderRadiusValue: 8,
                ),
              ),
            ),
            DataCell(
              SizedBox(
                width: 240,
                child: Text(
                  (site.name ?? '').toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
            DataCell(
              SizedBox(
                width: 160,
                child: Text(
                  (site.category ?? '').toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataCell(
              SizedBox(
                width: 160,
                child: Text(
                  (site.district ?? '').toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'View',
                    icon: const Icon(Icons.remove_red_eye, color: Color(0xFF3D5A80)),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SiteDetailPage(site: site))
                      );
                    },
                  ),
                  IconButton(
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit, color: Color(0xFF3D5A80)),
                    onPressed: () => _editSite(site),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteSite(siteId),
                  ),
                ],
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  // Mobile list view
  Widget _buildMobileList(List<CulturalSite> sites) {
    return ListView.separated(
      itemCount: sites.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final site =sites[index];
        String? imageUrl = getFirstImageUrl(site.imageUrls);
        int siteId = int.tryParse(site.id.toString()) ?? 0;

        String name = (site.name?? '').toString();
        String category = (site.category?? '').toString();
        String district = (site.district?? '').toString();

        String subtitle = [category, district]
            .where((value) => value.isNotEmpty)
            .join(' • ');

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SiteDetailPage(site: site))
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ProxyImage(
                      imageUrl: imageUrl,
                      width: 60,
                      height: 60,
                      borderRadiusValue: 8,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name and category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600]
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        icon: const Icon(Icons.edit, size: 20, color: Color(0xFF3D5A80)),
                        onPressed: () => _editSite(site),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () => _deleteSite(siteId),
                      ),
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
