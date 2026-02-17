import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import 'package:lokyatra_frontend/data/datasources/homestays_remote_datasource.dart';

import '../../state_management/Bloc/homestays/HomestayBloc.dart';
import '../../state_management/Bloc/homestays/HomestayEvent.dart';
import '../../state_management/Bloc/homestays/HomestayState.dart';
import 'HomestayAddPage.dart';
import 'HomestayDetailPage.dart';
import 'HomestayEditPage.dart';

class HomestayListingsPage extends StatefulWidget {
  const HomestayListingsPage({super.key});
  @override
  State<HomestayListingsPage> createState() => _HomestayListingsPageState();
}

class _HomestayListingsPageState extends State<HomestayListingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<HomestayBloc>().add(LoadMyHomestays());
  }

  // ─── Toggle visibility ───

  Future<void> _toggleVisibility(int id, bool currentValue) async {
    try {
      await HomestaysRemoteDatasource().toggleVisibility(id, !currentValue);
      if (mounted) context.read<HomestayBloc>().add(LoadMyHomestays());
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    }
  }

  // ─── Delete homestay ───

  Future<void> _deleteHomestay(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Homestay'),
        content: const Text('Are you sure you want to permanently delete this homestay? This cannot be undone.'),
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

    if (confirmed != true) return;

    try {
      final response = await HomestaysRemoteDatasource().deleteHomestay(id);
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Homestay deleted')));
        if (mounted) context.read<HomestayBloc>().add(LoadMyHomestays());
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  // ─── Navigate to Add page ───

  Future<void> _goToAddPage() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const HomestayAddPage()));
    if (result == true && mounted) {
      context.read<HomestayBloc>().add(LoadMyHomestays());
    }
  }

  // // ─── Navigate to Edit page ───
  //
  // Future<void> _goToEditPage(Map<String, dynamic> homestay) async {
  //   final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => HomestayEditPage(homestay: homestay)));
  //   if (result == true && mounted) {
  //     context.read<HomestayBloc>().add(LoadMyHomestays());
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Homestays'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _goToAddPage,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add New'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, foregroundColor: Colors.white),
            ),
          ),
        ],
      ),
      body: BlocBuilder<HomestayBloc, HomestayState>(
        builder: (context, state) {
          if (state is HomestayLoading) return const Center(child: CircularProgressIndicator());
          if (state is HomestayError) return Center(child: Text(state.message));
          if (state is HomestaysLoaded) {
            List<dynamic> homestays = state.homestays;
            if (homestays.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.holiday_village, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No homestays yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    SizedBox(height: 8),
                    Text('Tap "Add New" to create your first listing'),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: homestays.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                Map<String, dynamic> homestay = homestays[index] as Map<String, dynamic>;
                return _buildHomestayCard(homestay);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHomestayCard(Map<String, dynamic> homestay) {
    List<dynamic> imageUrls = homestay["imageUrls"] ?? [];
    String imageUrl = imageUrls.isNotEmpty ? imageUrls.first.toString() : "";
    String name = (homestay['name'] ?? '').toString();
    String location = (homestay['location'] ?? '').toString();
    double price = (homestay['pricePerNight'] ?? 0).toDouble();
    int rooms = homestay['numberOfRooms'] ?? 0;
    int guests = homestay['maxGuests'] ?? 0;
    bool isVisible = homestay['isVisible'] ?? true;
    int homestayId = homestay['id'] as int;

    // Get near cultural site name (we'll show the ID for now)
    String? nearSiteName = homestay['nearCulturalSite']?['name'];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with edit and view buttons
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      imageUrl.isEmpty
                          ? Icon(Icons.image, size: 50, color: Colors.grey)
                          : Image.network(
                        imageUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 150,
                            color: Colors.grey[100],
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        },
                      ),

                      Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(location, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      if (nearSiteName != null)
                        Text('Near: $nearSiteName')
                    ],
                  ),
                ),


              ],
            ),
            const SizedBox(height: 12),

            // Price and Capacity info boxes
            Row(
              children: [
                _buildInfoBox('Price/Night', 'Rs. ${price.toStringAsFixed(0)}'),
                const SizedBox(width: 12),
                _buildInfoBox('Capacity', '${rooms}R · ${guests}G'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoBox('Bookings', '0 total'),
                const SizedBox(width: 12),
                _buildInfoBox('Rating', 'No rating'),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isVisible ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isVisible ? 'Active' : 'Paused',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Text('Visible', style: TextStyle(color: Colors.grey[600])),
                Switch(
                  value: isVisible,
                  onChanged: (_) => _toggleVisibility(homestayId, isVisible),
                  activeThumbColor: Colors.green,
                ),
                Spacer(),


              ],
            ),
            Row(
              children: [
                IconButton(
                  tooltip: 'View',
                  onPressed: () => _goToDetailPage(homestay,context),
                  icon: const Icon(Icons.visibility, color: Colors.brown),
                ),
              Spacer(),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: () => _deleteHomestay(homestayId),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
                Spacer(),
                IconButton(
                  tooltip: 'Edit',
                  onPressed: () => _goToEditPage(homestay,context,mounted),
                  icon: const Icon(Icons.edit_outlined, color: Colors.brown),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

Future<void> _goToDetailPage(Map<String, dynamic> homestay, BuildContext context) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => HomestayDetailPage(homestay: homestay),
    ),
  );
}

Future<void> _goToEditPage(Map<String, dynamic> homestay, BuildContext context, bool mounted) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => HomestayEditPage(homestay: homestay),
    ),
  );

  if (result == true && mounted) {
    context.read<HomestayBloc>().add(LoadMyHomestays());
  }
}
