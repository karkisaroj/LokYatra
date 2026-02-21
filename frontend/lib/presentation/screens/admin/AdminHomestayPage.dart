import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/HomestayBloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/HomestayEvent.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/homestays/HomestayState.dart';
import '../../../data/models/Homestay.dart';

class Homestays extends StatefulWidget {
  final ValueNotifier subtitleNotifier;
  const Homestays({super.key, required this.subtitleNotifier});

  @override
  State<Homestays> createState() => _HomestaysState();
}

class _HomestaysState extends State<Homestays> {
  static const _terracotta = Color(0xFFCD6E4E);
  static const _dark = Color(0xFF2D1B10);
  static const _cream = Color(0xFFFAF7F2);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      widget.subtitleNotifier.value = "Manage Homestays";
    });
    context.read<HomestayBloc>().add(const TouristLoadAllHomestays());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _cream,
      child: BlocBuilder<HomestayBloc, HomestayState>(
        builder: (context, state) {
          if (state is HomestayLoading) {
            return const Center(child: CircularProgressIndicator(color: _terracotta));
          }

          if (state is HomestayError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48.sp, color: Colors.redAccent),
                  SizedBox(height: 16.h),
                  Text('Something went wrong',
                      style: GoogleFonts.playfairDisplay(fontSize: 20.sp, fontWeight: FontWeight.bold, color: _dark)),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Text(
                      'Please ensure the backend is running and you have admin permissions.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(fontSize: 14.sp, color: Colors.grey[600]),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () => context.read<HomestayBloc>().add(const TouristLoadAllHomestays()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _terracotta,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: Text('Retry', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            );
          }

          if (state is TouristAllHomestaysLoaded) {
            final homestays = state.homestays;

            if (homestays.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home_work_outlined, size: 60.sp, color: Colors.grey[400]),
                    SizedBox(height: 16.h),
                    Text('No Homestays Found',
                        style: GoogleFonts.playfairDisplay(fontSize: 22.sp, color: Colors.grey[800], fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              itemCount: homestays.length,
              itemBuilder: (context, index) {
                final homestay = homestays[index];
                final imageUrl = homestay.imageUrls.isNotEmpty ? homestay.imageUrls.first : null;
                final isVisible = homestay.isVisible;

                return Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(16.r)),
                        child: ProxyImage(
                          imageUrl: imageUrl, width: 110.w, height: 130.h, borderRadiusValue: 0, thumb: true,
                        ),
                      ),

                      // Details
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(homestay.name,
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.playfairDisplay(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _dark)),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 13.sp, color: Colors.grey[500]),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Text(homestay.location, maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[500])),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: isVisible ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(color: isVisible ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3)),
                                ),
                                child: Text(isVisible ? 'Active' : 'Paused',
                                    style: GoogleFonts.dmSans(fontSize: 11.sp, fontWeight: FontWeight.bold,
                                        color: isVisible ? Colors.green[700] : Colors.orange[800])),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Action Buttons
                      Column(
                        children: [
                          IconButton(
                            onPressed: () => _showVisibilityConfirmDialog(context, homestay),
                            icon: Icon(
                              isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: isVisible ? _terracotta : Colors.grey[600],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _showDeleteConfirmDialog(context, homestay),
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                          ),
                        ],
                      ),
                      SizedBox(width: 8.w),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ── Sleek Visibility Confirmation Dialog ──
  void _showVisibilityConfirmDialog(BuildContext context, Homestay homestay) {
    final isVisible = homestay.isVisible;
    final actionText = isVisible ? 'Pause' : 'Activate';
    final actionColor = isVisible ? Colors.orange[700] : Colors.green[600];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Icon(isVisible ? Icons.pause_circle_outline : Icons.play_circle_outline, color: actionColor, size: 28.sp),
            SizedBox(width: 10.w),
            Text('$actionText Homestay?', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 20.sp, color: _dark)),
          ],
        ),
        content: Text(
            isVisible
                ? 'Pausing "${homestay.name}" will hide it from tourists. They will not be able to book it until you activate it again.'
                : 'Activating "${homestay.name}" will make it immediately visible to all tourists for booking.',
            style: GoogleFonts.dmSans(fontSize: 14.sp, color: Colors.grey[700], height: 1.5)),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.dmSans(color: Colors.grey[600], fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HomestayBloc>().add(AdminToggleHomestayVisibility(homestay.id, !isVisible));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Homestay ${isVisible ? 'Paused' : 'Activated'}'), backgroundColor: actionColor));
            },
            child: Text(actionText, style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Sleek Delete Confirmation Dialog ──
  void _showDeleteConfirmDialog(BuildContext context, Homestay homestay) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28.sp),
            SizedBox(width: 10.w),
            Text('Delete Homestay?', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 20.sp, color: _dark)),
          ],
        ),
        content: Text('Are you sure you want to permanently delete "${homestay.name}"? This action cannot be undone.',
            style: GoogleFonts.dmSans(fontSize: 14.sp, color: Colors.grey[700], height: 1.5)),
        actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.dmSans(color: Colors.grey[600], fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HomestayBloc>().add(AdminDeleteHomestay(homestay.id));
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Homestay deleted successfully'), backgroundColor: Colors.redAccent));
            },
            child: Text('Delete', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}