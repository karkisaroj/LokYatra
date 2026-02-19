import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/HomestayDetailPage.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/HomestayEditPage.dart';
import '../../state_management/Bloc/homestays/HomestayBloc.dart';
import '../../state_management/Bloc/homestays/HomestayEvent.dart';
import '../../state_management/Bloc/homestays/HomestayState.dart';
import 'HomestayAddPage.dart';

class HomestayListingsPage extends StatefulWidget {
  const HomestayListingsPage({super.key});

  @override
  State<HomestayListingsPage> createState() => _HomestayListingsPageState();
}

class _HomestayListingsPageState extends State<HomestayListingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<HomestayBloc>().add(const LoadMyHomestays());
  }

  void _goToDetail(Homestay homestay) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HomestayDetailPage(homestay: homestay),
      ),
    ).then((_) {
      if (mounted) {
        context.read<HomestayBloc>().add(const LoadMyHomestays());
      }
    });
  }

  void _goToEdit(Homestay homestay) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HomestayEditPage(homestay: homestay),
      ),
    ).then((updated) {
      if (updated == true && mounted) {
        context.read<HomestayBloc>().add(const LoadMyHomestays());
      }
    });
  }

  void _goToAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HomestayAddPage()),
    ).then((added) {
      if (added == true && mounted) {
        context.read<HomestayBloc>().add(const LoadMyHomestays());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('My Homestays',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: BlocBuilder<HomestayBloc, HomestayState>(
        builder: (context, state) {
          if (state is HomestayLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomestayError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Error: ${state.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<HomestayBloc>()
                        .add(const LoadMyHomestays()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is HomestaysLoaded) {
            if (state.homestays.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text('No homestays yet',
                        style:
                        TextStyle(fontSize: 18, color: Colors.grey)),
                    const SizedBox(height: 8),
                    const Text('Tap + to add your first homestay',
                        style:
                        TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              itemCount: state.homestays.length,
              itemBuilder: (context, index) {
                final homestay = state.homestays[index];
                return _HomestayCard(
                  homestay: homestay,
                  onTap: () => _goToDetail(homestay),
                  onEdit: () => _goToEdit(homestay),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToAdd,
        icon: const Icon(Icons.add),
        label: const Text('Add Homestay'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _HomestayCard extends StatelessWidget {
  final Homestay homestay;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _HomestayCard({
    required this.homestay,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final firstImage = homestay.imageUrls.isNotEmpty
        ? homestay.imageUrls.first
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Stack(
              children: [
                firstImage != null
                    ? ProxyImage(
                  imageUrl: firstImage,
                  width: double.infinity,
                  height: 180,
                  borderRadiusValue: 0,
                )
                    : Container(
                  width: double.infinity,
                  height: 180,
                  color: Colors.grey[200],
                  child: const Icon(Icons.home,
                      size: 64, color: Colors.grey),
                ),

                // Active / Inactive badge top-left
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: homestay.isVisible
                          ? Colors.green
                          : Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          homestay.isVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          homestay.isVisible ? 'Active' : 'Inactive',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (homestay.category!.isNotEmpty)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        homestay.category!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Details row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          homestay.name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                homestay.location,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              'Rs. ${homestay.pricePerNight.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            ),
                            const Text(' / night',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _miniChip(Icons.bed,
                                '${homestay.numberOfRooms}'),
                            const SizedBox(width: 6),
                            _miniChip(Icons.people,
                                '${homestay.maxGuests}'),
                            const SizedBox(width: 6),
                            _miniChip(Icons.bathtub_outlined,
                                '${homestay.bathrooms}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: Colors.blueGrey),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniChip(IconData icon, String label) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey[600]),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: Colors.grey[700])),
      ],
    ),
  );
}