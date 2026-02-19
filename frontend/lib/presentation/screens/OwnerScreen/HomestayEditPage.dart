import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import 'package:lokyatra_frontend/data/datasources/homestays_remote_datasource.dart';
import 'package:lokyatra_frontend/data/datasources/sites_remote_datasource.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';

class HomestayEditPage extends StatefulWidget {
  final Homestay homestay;
  const HomestayEditPage({super.key, required this.homestay});

  @override
  State<HomestayEditPage> createState() => _HomestayEditPageState();
}

class _HomestayEditPageState extends State<HomestayEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _sitesLoading = true;

  late final TextEditingController _name;
  late final TextEditingController _location;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _rooms;
  late final TextEditingController _guests;
  late final TextEditingController _bathrooms;
  late final TextEditingController _buildingHistory;
  late final TextEditingController _traditionalFeatures;
  late final TextEditingController _culturalExperiences;
  late final TextEditingController _culturalSignificance;

  String? _selectedCategory;
  int? _selectedSiteId;
  List<dynamic> _sites = [];

  static const _allAmenities = [
    'WiFi', 'Parking', 'Hot Water', 'Air Conditioning', 'Heating',
    'Kitchen', 'Breakfast Included', 'Laundry', 'Garden', 'Terrace',
    'Mountain View', 'River View', 'TV', 'Bonfire', 'Guided Tours', 'Bicycle Rental',
  ];
  late Set<String> _selectedAmenities;

  late List<String> _existingImages;
  final List<PlatformFile?> _newImages = [null, null, null, null];
  late bool _isVisible;

  static const _brown = Color(0xFF5C4033);
  final _categories = ['homestay', 'guest_house', 'traditional'];

  @override
  void initState() {
    super.initState();
    final h = widget.homestay;
    _name = TextEditingController(text: h.name);
    _location = TextEditingController(text: h.location);
    _description = TextEditingController(text: h.description);
    _price = TextEditingController(text: h.pricePerNight.toStringAsFixed(0));
    _rooms = TextEditingController(text: h.numberOfRooms.toString());
    _guests = TextEditingController(text: h.maxGuests.toString());
    _bathrooms = TextEditingController(text: h.bathrooms.toString());
    _buildingHistory = TextEditingController(text: h.buildingHistory ?? '');
    _traditionalFeatures = TextEditingController(text: h.traditionalFeatures ?? '');
    _culturalExperiences = TextEditingController(text: h.culturalExperiences.join(', '));
    _culturalSignificance = TextEditingController(text: h.culturalSignificance ?? '');

    _selectedCategory = h.category;
    _selectedSiteId = h.nearCulturalSite?.id;
    _isVisible = h.isVisible;
    _selectedAmenities = h.amenities.map((a) => a.trim()).where((a) => a.isNotEmpty).toSet();

    _existingImages = List.filled(4, '');
    for (int i = 0; i < 4 && i < h.imageUrls.length; i++) {
      _existingImages[i] = h.imageUrls[i];
    }
    _loadSites();
  }

  @override
  void dispose() {
    for (final c in [_name, _location, _description, _price, _rooms, _guests,
      _bathrooms, _buildingHistory, _traditionalFeatures, _culturalExperiences,
      _culturalSignificance]) {
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
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _newImages[i] = result.files.first;
        _existingImages[i] = '';
      });
    }
  }

  void _removeImage(int i) => setState(() {
    _newImages[i] = null;
    _existingImages[i] = '';
  });

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final res = await HomestaysRemoteDatasource().updateHomestay(
        id: widget.homestay.id,
        fields: {
          'Name': _name.text.trim(),
          'Location': _location.text.trim(),
          'Description': _description.text.trim(),
          'PricePerNight': _price.text.trim(),
          'NumberOfRooms': _rooms.text.trim(),
          'MaxGuests': _guests.text.trim(),
          'Bathrooms': _bathrooms.text.trim(),
          'BuildingHistory': _buildingHistory.text.trim(),
          'TraditionalFeatures': _traditionalFeatures.text.trim(),
          'CulturalExperiences': _culturalExperiences.text.trim(),
          'CulturalSignificance': _culturalSignificance.text.trim(),
          'Amenities': _selectedAmenities.join(','),
          'IsVisible': _isVisible.toString(),
          if (_selectedCategory != null) 'Category': _selectedCategory!,
          if (_selectedSiteId != null) 'NearCulturalSiteId': _selectedSiteId.toString(),
        },
        files: _newImages.whereType<PlatformFile>().toList(),
      );
      if ((res.statusCode == 200 || res.statusCode == 204) && mounted) {
        Navigator.pop(context, true);
      } else {
        _snack('Update failed: ${res.statusMessage}');
      }
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg, style: GoogleFonts.dmSans())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Edit Homestay',
            style: GoogleFonts.playfairDisplay(
                fontSize: 18.sp, fontWeight: FontWeight.bold,
                color: const Color(0xFF2D1B10))),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _submit,
            icon: Icon(Icons.save, color: _brown, size: 18.sp),
            label: Text('Save',
                style: GoogleFonts.dmSans(
                    color: _brown, fontWeight: FontWeight.bold, fontSize: 14.sp)),
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
              // Visibility toggle
              _card(child: SwitchListTile(
                title: Text('Listing Active',
                    style: GoogleFonts.dmSans(
                        fontSize: 14.sp, fontWeight: FontWeight.w600)),
                subtitle: Text(_isVisible ? 'Visible to guests' : 'Hidden from guests',
                    style: GoogleFonts.dmSans(fontSize: 12.sp)),
                value: _isVisible,
                activeThumbColor: Colors.green,
                onChanged: (val) => setState(() => _isVisible = val),
              )),
              SizedBox(height: 4.h),

              _section('Basic Information', Icons.home_outlined, [
                _field(_name, 'Name'),
                _field(_location, 'Location'),
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
                Text('Tap a site to select it',
                    style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey)),
                SizedBox(height: 10.h),
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
                _amenityChips(),
              ]),

              _section('Photos', Icons.photo_library_outlined, [
                Text('Tap a slot to change · Tap ✕ to remove',
                    style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey)),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 12.w,
                  runSpacing: 12.h,
                  children: List.generate(4, _imageSlot),
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
                  icon: Icon(Icons.save, size: 18.sp),
                  label: Text('Save Changes',
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

  Widget _card({required Widget child}) => Container(
    margin: EdgeInsets.only(bottom: 14.h),
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
    child: child,
  );

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
            Row(children: [
              Icon(icon, size: 18.sp, color: _brown),
              SizedBox(width: 8.w),
              Text(title,
                  style: GoogleFonts.dmSans(
                      fontSize: 14.sp, fontWeight: FontWeight.bold)),
            ]),
            SizedBox(height: 14.h),
            ...children,
          ],
        ),
      );

  Widget _field(TextEditingController ctrl, String label,
      {int lines = 1, bool number = false, bool required = true, String? hint}) =>
      Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: TextFormField(
          controller: ctrl,
          maxLines: lines,
          keyboardType: number
              ? const TextInputType.numberWithOptions(decimal: true)
              : null,
          style: GoogleFonts.dmSans(fontSize: 14.sp),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.dmSans(fontSize: 13.sp),
            hintText: hint,
            hintStyle:
            GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[400]),
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

  Widget _categoryDropdown() => Padding(
    padding: EdgeInsets.only(bottom: 12.h),
    child: DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      style: GoogleFonts.dmSans(fontSize: 14.sp, color: Colors.black87),
      decoration: InputDecoration(
        labelText: 'Category',
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
    if (_sitesLoading) return const Center(child: CircularProgressIndicator());
    if (_sites.isEmpty) {
      return Text('No sites available.',
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
      final selected = _selectedAmenities
          .any((s) => s.toLowerCase() == a.toLowerCase());
      return FilterChip(
        label: Text(a, style: GoogleFonts.dmSans(fontSize: 12.sp)),
        selected: selected,
        onSelected: (val) => setState(() {
          if (val) {
            _selectedAmenities.add(a);
          } else {
            _selectedAmenities
                .removeWhere((s) => s.toLowerCase() == a.toLowerCase());
          }
        }),
        selectedColor: _brown.withValues(alpha: 0.12),
        checkmarkColor: _brown,
        side: BorderSide(color: selected ? _brown : Colors.grey.shade300),
        backgroundColor: const Color(0xFFFAF9F7),
      );
    }).toList(),
  );

  Widget _imageSlot(int i) {
    final newFile = _newImages[i];
    final existing = _existingImages[i];
    final hasContent = newFile != null || existing.isNotEmpty;

    return GestureDetector(
      onTap: () => _pickImage(i),
      child: Container(
        height: 100.h,
        width: 100.w,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(
            color: hasContent ? _brown : Colors.grey.shade300,
            width: hasContent ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Stack(fit: StackFit.expand, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: newFile != null
                ? Image.file(File(newFile.path!), fit: BoxFit.cover)
                : existing.isNotEmpty
                ? ProxyImage(
                imageUrl: existing,
                width: double.infinity,
                height: double.infinity,
                borderRadiusValue: 0)
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate,
                    size: 28.sp, color: Colors.grey[400]),
                SizedBox(height: 4.h),
                Text('Slot ${i + 1}',
                    style: GoogleFonts.dmSans(
                        fontSize: 10.sp, color: Colors.grey[400])),
              ],
            ),
          ),
          if (hasContent)
            Positioned(
              top: 4.h,
              right: 4.w,
              child: GestureDetector(
                onTap: () => _removeImage(i),
                child: CircleAvatar(
                  radius: 11.r,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, size: 12.sp, color: Colors.white),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}