import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/data/datasources/homestays_remote_datasource.dart';
import 'package:lokyatra_frontend/data/datasources/sites_remote_datasource.dart';
import '../../widgets/Helpers/form_helpers.dart';

class HomestayAddPage extends StatefulWidget {
  const HomestayAddPage({super.key});

  @override
  State<HomestayAddPage> createState() => _HomestayAddPageState();
}

class _HomestayAddPageState extends State<HomestayAddPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _sitesLoading = true;

  final _name = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();
  final _buildingHistory = TextEditingController();
  final _traditionalFeatures = TextEditingController();
  final _culturalExperiences = TextEditingController();
  final _culturalSignificance = TextEditingController();
  final _price = TextEditingController();
  final _rooms = TextEditingController();
  final _guests = TextEditingController();
  final _bathrooms = TextEditingController();

  String? _selectedCategory;
  int? _selectedSiteId;
  List<dynamic> _sites = [];
  final List<PlatformFile?> _images = [null, null, null, null];

  final _categories = ['homestay', 'guest_house', 'traditional'];

  static const _allAmenities = [
    'WiFi', 'Parking', 'Hot Water', 'Air Conditioning', 'Heating',
    'Kitchen', 'Breakfast Included', 'Laundry', 'Garden', 'Terrace',
    'Mountain View', 'River View', 'TV', 'Bonfire', 'Guided Tours', 'Bicycle Rental',
  ];
  final Set<String> _selectedAmenities = {};

  static const _brown = Color(0xFF5C4033);

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  @override
  void dispose() {
    for (final c in [_name, _location, _description, _buildingHistory,
      _traditionalFeatures, _culturalExperiences, _culturalSignificance,
      _price, _rooms, _guests, _bathrooms]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSites() async {
    try {
      final res = await SitesRemoteDatasource().getSites();
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _sites = res.data as List<dynamic>;
          _sitesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _sitesLoading = false);
    }
  }

  Future<void> _pickImage(int i) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && mounted) setState(() => _images[i] = result.files.first);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      FormHelpers.showSnack(context, 'Please select a category');
      return;
    }
    if (_selectedSiteId == null) {
      FormHelpers.showSnack(context, 'Please select a cultural site');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await HomestaysRemoteDatasource().createHomestay(
        fields: {
          'Name': _name.text.trim(),
          'Location': _location.text.trim(),
          'Description': _description.text.trim(),
          'Category': _selectedCategory,
          'PricePerNight': _price.text.trim(),
          'NearCulturalSiteId': _selectedSiteId,
          'NumberOfRooms': _rooms.text.trim(),
          'MaxGuests': _guests.text.trim(),
          'Bathrooms': _bathrooms.text.trim(),
          'BuildingHistory': _buildingHistory.text.trim(),
          'TraditionalFeatures': _traditionalFeatures.text.trim(),
          'CulturalExperiences': _culturalExperiences.text.trim(),
          'CulturalSignificance': _culturalSignificance.text.trim(),
          'Amenities': _selectedAmenities.join(','),
        },
        files: _images.whereType<PlatformFile>().toList(),
      );
      if (res.statusCode == 200 && mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) FormHelpers.showSnack(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Add Homestay',
            style: GoogleFonts.playfairDisplay(
                fontSize: 18.sp, fontWeight: FontWeight.bold,
                color: const Color(0xFF2D1B10))),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: _isLoading
                ? Center(
                child: SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(strokeWidth: 2)))
                : TextButton.icon(
              onPressed: _submit,
              icon: Icon(Icons.check, color: Colors.green, size: 18.sp),
              label: Text('Upload',
                  style: GoogleFonts.dmSans(
                      color: _brown, fontWeight: FontWeight.bold,
                      fontSize: 14.sp)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('Basic Information', Icons.home_outlined, [
                _field(_name, 'Homestay Name'),
                _field(_location, 'Location', hint: 'e.g. Bhaktapur, Kathmandu Valley'),
                _field(_description, 'Description', lines: 4),
                _categoryDropdown(),
              ]),

              _section('Pricing & Capacity', Icons.payments_outlined, [
                _field(_price, 'Price per Night (Rs.)', number: true),
                Row(children: [
                  Expanded(child: _field(_rooms, 'Rooms', number: true)),
                  SizedBox(width: 10.w),
                  Expanded(child: _field(_guests, 'Max Guests', number: true)),
                  SizedBox(width: 10.w),
                  Expanded(child: _field(_bathrooms, 'Bathrooms', number: true)),
                ]),
              ]),

              _section('Near Cultural Site', Icons.temple_hindu_outlined, [
                _siteSelector(),
              ]),

              _section('Cultural Heritage', Icons.auto_stories_outlined, [
                _field(_culturalSignificance, 'Cultural Significance',
                    lines: 3, required: false),
                _field(_buildingHistory, 'Building History',
                    lines: 3, required: false),
                _field(_traditionalFeatures, 'Traditional Features',
                    lines: 3, required: false),
                _field(_culturalExperiences, 'Cultural Experiences',
                    lines: 3, required: false,
                    hint: 'e.g. Thangka painting, Mask dance'),
              ]),

              _section('Amenities', Icons.checklist_outlined, [
                Text('Select everything your homestay offers',
                    style: GoogleFonts.dmSans(
                        fontSize: 12.sp, color: Colors.grey)),
                SizedBox(height: 12.h),
                _amenityChips(),
              ]),

              _section('Photos', Icons.photo_library_outlined, [
                Text('Add up to 4 photos · Tap a slot to upload',
                    style: GoogleFonts.dmSans(
                        fontSize: 12.sp, color: Colors.grey)),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 12.w,
                  runSpacing: 12.h,
                  children: List.generate(4, _imageBox),
                ),
              ]),

              SizedBox(height: 20.h),

              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                  onPressed: _submit,
                  icon: Icon(Icons.publish, size: 18.sp),
                  label: Text('Upload Homestay',
                      style: GoogleFonts.dmSans(
                          fontSize: 15.sp, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brown,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, IconData icon, List<Widget> children) =>
      Container(
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18.sp, color: _brown),
                SizedBox(width: 8.w),
                Text(title,
                    style: GoogleFonts.dmSans(
                        fontSize: 14.sp, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 14.h),
            ...children,
          ],
        ),
      );

  Widget _field(TextEditingController ctrl, String label,
      {int lines = 1, bool number = false, bool required = true, String? hint}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: ctrl,
        maxLines: lines,
        keyboardType:
        number ? const TextInputType.numberWithOptions(decimal: true) : null,
        style: GoogleFonts.dmSans(fontSize: 14.sp),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.dmSans(fontSize: 13.sp),
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[400]),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: _brown, width: 1.5)),
          filled: true,
          fillColor: const Color(0xFFFAF9F7),
          contentPadding:
          EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        ),
        validator: required
            ? (v) => (v?.trim().isEmpty ?? true) ? '$label is required' : null
            : null,
      ),
    );
  }

  Widget _categoryDropdown() => Padding(
    padding: EdgeInsets.only(bottom: 12.h),
    child: DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      style: GoogleFonts.dmSans(fontSize: 14.sp, color: Colors.black87),
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: GoogleFonts.dmSans(fontSize: 13.sp),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: _brown, width: 1.5)),
        filled: true,
        fillColor: const Color(0xFFFAF9F7),
        contentPadding:
        EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      ),
      items: _categories
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (val) => setState(() => _selectedCategory = val),
    ),
  );

  Widget _siteSelector() {
    if (_sitesLoading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ));
    }
    if (_sites.isEmpty) {
      return Text('No cultural sites available.',
          style: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey));
    }
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10.r),
        color: const Color(0xFFFAF9F7),
      ),
      child: ListView.builder(
        itemCount: _sites.length,
        itemBuilder: (_, i) {
          final site = _sites[i];
          final id = site['id'] as int?;
          final name = site['name']?.toString() ?? 'Unnamed';
          final selected = _selectedSiteId == id;
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16.r,
              backgroundColor: selected ? _brown : Colors.grey.shade200,
              child: Icon(Icons.temple_hindu,
                  size: 14.sp,
                  color: selected ? Colors.white : Colors.grey),
            ),
            title: Text(name,
                style: GoogleFonts.dmSans(
                    fontSize: 13.sp,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
            trailing: selected
                ? Icon(Icons.check_circle, color: _brown, size: 18.sp)
                : null,
            onTap: () => setState(() => _selectedSiteId = id),
          );
        },
      ),
    );
  }

  Widget _amenityChips() => Wrap(
    spacing: 8.w,
    runSpacing: 8.h,
    children: _allAmenities.map((a) {
      final selected = _selectedAmenities.contains(a);
      return FilterChip(
        label: Text(a, style: GoogleFonts.dmSans(fontSize: 12.sp)),
        selected: selected,
        onSelected: (val) => setState(() =>
        val ? _selectedAmenities.add(a) : _selectedAmenities.remove(a)),
        selectedColor: _brown.withValues(alpha: 0.12),
        checkmarkColor: _brown,
        side: BorderSide(color: selected ? _brown : Colors.grey.shade300),
        backgroundColor: const Color(0xFFFAF9F7),
      );
    }).toList(),
  );

  Widget _imageBox(int i) {
    final file = _images[i];
    return GestureDetector(
      onTap: () => _pickImage(i),
      child: Container(
        height: 100.h,
        width: 100.w,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(
            color: file != null ? _brown : Colors.grey.shade300,
            width: file != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: file != null
            ? Stack(fit: StackFit.expand, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.file(File(file.path!), fit: BoxFit.cover),
          ),
          Positioned(
            top: 4.h,
            right: 4.w,
            child: GestureDetector(
              onTap: () => setState(() => _images[i] = null),
              child: CircleAvatar(
                radius: 11.r,
                backgroundColor: Colors.red,
                child: Icon(Icons.close, size: 12.sp, color: Colors.white),
              ),
            ),
          ),
        ])
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate,
                size: 28.sp, color: Colors.grey[400]),
            SizedBox(height: 4.h),
            Text('Photo ${i + 1}',
                style: GoogleFonts.dmSans(
                    fontSize: 10.sp, color: Colors.grey[400])),
          ],
        ),
      ),
    );
  }
}