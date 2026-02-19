import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
  static const _brown = Color(0xFF5C4033);

  @override
  void initState() {
    super.initState();
    context.read<HomestayBloc>().add(const LoadMyHomestays());
  }

  void _reload() {
    if (mounted) context.read<HomestayBloc>().add(const LoadMyHomestays());
  }

  void _goToDetail(Homestay h) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => HomestayDetailPage(homestay: h)))
          .then((_) => _reload());

  void _goToEdit(Homestay h) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => HomestayEditPage(homestay: h)))
          .then((updated) { if (updated == true) _reload(); });

  void _goToAdd() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HomestayAddPage()))
          .then((added) { if (added == true) _reload(); });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('My Homestays',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20.sp, fontWeight: FontWeight.bold,
                color: const Color(0xFF2D1B10))),
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
                  Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                  SizedBox(height: 12.h),
                  Text('Error: ${state.message}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                          fontSize: 14.sp, color: Colors.grey)),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: _reload,
                    style: ElevatedButton.styleFrom(backgroundColor: _brown),
                    child: Text('Retry',
                        style: GoogleFonts.dmSans(color: Colors.white)),
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
                    Icon(Icons.home_outlined, size: 64.sp, color: Colors.grey[300]),
                    SizedBox(height: 16.h),
                    Text('No homestays yet',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 20.sp, color: Colors.grey[600])),
                    SizedBox(height: 8.h),
                    Text('Tap + to add your first homestay',
                        style: GoogleFonts.dmSans(
                            fontSize: 13.sp, color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              itemCount: state.homestays.length,
              itemBuilder: (_, i) {
                final homestay = state.homestays[i];
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
        backgroundColor: _brown,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add, size: 20.sp),
        label: Text('Add Homestay',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
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
    final firstImage =
    homestay.imageUrls.isNotEmpty ? homestay.imageUrls.first : null;

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + badges
            Stack(
              children: [
                firstImage != null
                    ? ProxyImage(
                  imageUrl: firstImage,
                  width: double.infinity,
                  height: 180.h,
                  borderRadiusValue: 0,
                )
                    : Container(
                  width: double.infinity,
                  height: 180.h,
                  color: Colors.grey[200],
                  child: Icon(Icons.home, size: 64.sp, color: Colors.grey[400]),
                ),

                // Active / Inactive badge
                Positioned(
                  top: 10.h,
                  left: 10.w,
                  child: _badge(
                    label: homestay.isVisible ? 'Active' : 'Inactive',
                    icon: homestay.isVisible ? Icons.visibility : Icons.visibility_off,
                    color: homestay.isVisible ? Colors.green : Colors.grey.shade600,
                  ),
                ),

                // Category badge
                if (homestay.category != null && homestay.category!.isNotEmpty)
                  Positioned(
                    top: 10.h,
                    right: 10.w,
                    child: _badge(
                      label: homestay.category!,
                      color: const Color(0xFF5C4033),
                    ),
                  ),
              ],
            ),

            // Details
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 8.w, 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(homestay.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 17.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 13.sp, color: Colors.grey),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(homestay.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 12.sp, color: Colors.grey)),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                'Rs. ${homestay.pricePerNight.toStringAsFixed(0)}',
                                style: GoogleFonts.dmSans(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF5C4033)),
                              ),
                              TextSpan(
                                text: ' / night',
                                style: GoogleFonts.dmSans(
                                    fontSize: 12.sp, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            _miniChip(Icons.bed_outlined, '${homestay.numberOfRooms}'),
                            SizedBox(width: 6.w),
                            _miniChip(Icons.people_outline, '${homestay.maxGuests}'),
                            SizedBox(width: 6.w),
                            _miniChip(Icons.bathtub_outlined, '${homestay.bathrooms}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_outlined,
                        color: const Color(0xFF5C4033), size: 22.sp),
                    onPressed: onEdit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge({required String label, IconData? icon, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 11.sp),
            SizedBox(width: 4.w),
          ],
          Text(label,
              style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _miniChip(IconData icon, String label) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11.sp, color: Colors.grey[600]),
        SizedBox(width: 3.w),
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 10.sp, color: Colors.grey[700])),
      ],
    ),
  );
}