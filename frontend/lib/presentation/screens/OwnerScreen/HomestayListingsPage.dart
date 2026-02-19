import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/HomestayDetailPage.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/HomestayEditPage.dart';
import '../../state_management/Bloc/homestays/HomestayBloc.dart';
import '../../state_management/Bloc/homestays/HomestayEvent.dart';
import '../../state_management/Bloc/homestays/HomestayState.dart';
import 'HomestayAddPage.dart';

class HomestayListingsPage extends StatelessWidget {
  const HomestayListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<HomestayBloc>().add(const LoadMyHomestays());

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Homestays'),
      ),
      body: BlocBuilder<HomestayBloc, HomestayState>(
        builder: (context, state) {
          if (state is HomestayLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomestaysLoaded) {
            if (state.homestays.isEmpty) {
              return const Center(child: Text('No homestays found'));
            }
            return ListView.builder(
              itemCount: state.homestays.length,
              itemBuilder: (context, index) {
                final homestay = state.homestays[index];
                final firstImage = getFirstImageUrl(homestay.imageUrls);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomestayDetailPage(homestay: homestay),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: firstImage != null
                              ? ProxyImage(
                            imageUrl: firstImage,
                            width: double.infinity,
                            height: 200,
                            borderRadiusValue: 0,
                          )
                              : Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.home, size: 80, color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      homestay.name,
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      homestay.location,
                                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rs. ${homestay.pricePerNight.toStringAsFixed(0)} / night',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomestayEditPage(homestay: homestay),
                                    ),
                                  ).then((updated) {
                                    if (updated == true) {
                                      context.read<HomestayBloc>().add(const LoadMyHomestays());
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is HomestayError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('Press to load'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomestayAddPage()),
          ).then((added) {
            if (added == true) {
              context.read<HomestayBloc>().add(const LoadMyHomestays());
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}