import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/OwnerHomestayDetailPage.dart';
import 'package:lokyatra_frontend/presentation/screens/OwnerScreen/HomestayEditPage.dart';
import '../../state_management/Bloc/homestays/HomestayBloc.dart';
import '../../state_management/Bloc/homestays/HomestayEvent.dart';
import '../../state_management/Bloc/homestays/HomestayState.dart';
import 'HomestayAddPage.dart';

const Color kBrown = Color(0xFF5C4033);
const Color kDarkInk = Color(0xFF2D1B10);
const Color kBg = Color(0xFFF5F4F2);

double fs(double v, bool wide) => wide ? v : v.sp;
double sw(double v, bool wide) => wide ? v : v.w;
double sh(double v, bool wide) => wide ? v : v.h;
double sr(double v, bool wide) => wide ? v : v.r;

class HomestayListingsPage extends StatefulWidget {
  const HomestayListingsPage({super.key});
  @override
  State<HomestayListingsPage> createState() => HomestayListingsPageState();
}

class HomestayListingsPageState extends State<HomestayListingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<HomestayBloc>().add(const OwnerLoadMyHomestays());
  }

  void reload() {
    if (mounted) context.read<HomestayBloc>().add(const OwnerLoadMyHomestays());
  }

  void goToDetail(Homestay h) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => OwnerHomestayDetailPage(homestay: h)))
          .then((_) => reload());

  void goToEdit(Homestay h) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => HomestayEditPage(homestay: h)))
          .then((updated) { if (updated == true) reload(); });

  void goToAdd() =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HomestayAddPage()))
          .then((added) { if (added == true) reload(); });

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Homestays',
          style: GoogleFonts.playfairDisplay(
            fontSize: fs(20, wide),
            fontWeight: FontWeight.bold,
            color: kDarkInk,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
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
                  Icon(Icons.error_outline, size: fs(48, wide), color: Colors.red),
                  SizedBox(height: sh(12, wide)),
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(fontSize: fs(14, wide), color: Colors.grey),
                  ),
                  SizedBox(height: sh(16, wide)),
                  ElevatedButton(
                    onPressed: reload,
                    style: ElevatedButton.styleFrom(backgroundColor: kBrown),
                    child: Text('Retry', style: GoogleFonts.dmSans(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          if (state is OwnerHomestaysLoaded) {
            if (state.homestays.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home_outlined, size: fs(64, wide), color: Colors.grey[300]),
                    SizedBox(height: sh(16, wide)),
                    Text(
                      'No homestays yet',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: fs(20, wide),
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: sh(8, wide)),
                    Text(
                      'Tap + to add your first homestay',
                      style: GoogleFonts.dmSans(fontSize: fs(13, wide), color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: wide ? 900 : double.infinity),
                child: wide
                    ? GridView.builder(
                  padding: EdgeInsets.all(sw(20, wide)),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: state.homestays.length,
                  itemBuilder: (_, i) {
                    final h = state.homestays[i];
                    return HomestayCard(
                      wide: wide,
                      homestay: h,
                      onTap: () => goToDetail(h),
                      onEdit: () => goToEdit(h),
                    );
                  },
                )
                    : ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw(16, wide),
                    vertical: sh(12, wide),
                  ),
                  itemCount: state.homestays.length,
                  itemBuilder: (_, i) {
                    final h = state.homestays[i];
                    return HomestayCard(
                      wide: wide,
                      homestay: h,
                      onTap: () => goToDetail(h),
                      onEdit: () => goToEdit(h),
                    );
                  },
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: goToAdd,
        backgroundColor: kBrown,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add, size: fs(20, wide)),
        label: Text('Add Homestay', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class HomestayCard extends StatelessWidget {
  final bool wide;
  final Homestay homestay;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const HomestayCard({
    super.key,
    required this.wide,
    required this.homestay,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final String? firstImage = homestay.imageUrls.isNotEmpty ? homestay.imageUrls.first : null;
    final double imgHeight = wide ? 180 : 180.h;

    return Card(
      margin: wide ? EdgeInsets.zero : EdgeInsets.only(bottom: sh(16, wide)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sr(16, wide))),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                firstImage != null
                    ? ProxyImage(
                  imageUrl: firstImage,
                  width: double.infinity,
                  height: imgHeight,
                  borderRadiusValue: 0,
                )
                    : Container(
                  width: double.infinity,
                  height: imgHeight,
                  color: Colors.grey[200],
                  child: Icon(Icons.home, size: fs(64, wide), color: Colors.grey[400]),
                ),
                Positioned(
                  top: sh(10, wide),
                  left: sw(10, wide),
                  child: StatusBadge(
                    wide: wide,
                    label: homestay.isVisible ? 'Active' : 'Inactive',
                    icon: homestay.isVisible ? Icons.visibility : Icons.visibility_off,
                    color: homestay.isVisible ? Colors.green : Colors.grey.shade600,
                  ),
                ),
                if (homestay.category != null && homestay.category!.isNotEmpty)
                  Positioned(
                    top: sh(10, wide),
                    right: sw(10, wide),
                    child: StatusBadge(
                      wide: wide,
                      label: homestay.category!,
                      color: kBrown,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(sw(14, wide), sh(12, wide), sw(8, wide), sh(12, wide)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          homestay.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: fs(17, wide),
                            fontWeight: FontWeight.bold,
                            color: kDarkInk,
                          ),
                        ),
                        SizedBox(height: sh(4, wide)),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: fs(13, wide), color: Colors.grey),
                            SizedBox(width: sw(2, wide)),
                            Expanded(
                              child: Text(
                                homestay.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.dmSans(
                                  fontSize: fs(12, wide),
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: sh(6, wide)),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Rs. ${homestay.pricePerNight.toStringAsFixed(0)}',
                                style: GoogleFonts.dmSans(
                                  fontSize: fs(15, wide),
                                  fontWeight: FontWeight.bold,
                                  color: kBrown,
                                ),
                              ),
                              TextSpan(
                                text: ' / night',
                                style: GoogleFonts.dmSans(
                                  fontSize: fs(12, wide),
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: sh(8, wide)),
                        Row(
                          children: [
                            InfoChip(wide: wide, icon: Icons.bed_outlined, label: '${homestay.numberOfRooms}'),
                            SizedBox(width: sw(6, wide)),
                            InfoChip(wide: wide, icon: Icons.people_outline, label: '${homestay.maxGuests}'),
                            SizedBox(width: sw(6, wide)),
                            InfoChip(wide: wide, icon: Icons.bathtub_outlined, label: '${homestay.bathrooms}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: kBrown, size: fs(22, wide)),
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
}

class StatusBadge extends StatelessWidget {
  final bool wide;
  final String label;
  final IconData? icon;
  final Color color;

  const StatusBadge({
    super.key,
    required this.wide,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw(10, wide), vertical: sh(5, wide)),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(sr(20, wide)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: fs(11, wide)),
            SizedBox(width: sw(4, wide)),
          ],
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontSize: fs(11, wide),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  final bool wide;
  final IconData icon;
  final String label;

  const InfoChip({super.key, required this.wide, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw(8, wide), vertical: sh(3, wide)),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(sr(20, wide)),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fs(11, wide), color: Colors.grey[600]),
          SizedBox(width: sw(3, wide)),
          Text(
            label,
            style: GoogleFonts.dmSans(fontSize: fs(10, wide), color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}