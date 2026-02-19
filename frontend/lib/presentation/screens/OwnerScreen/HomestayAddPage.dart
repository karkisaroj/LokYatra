import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _buildingHistoryController = TextEditingController();
  final _traditionalFeaturesController = TextEditingController();
  final _culturalExperiencesController = TextEditingController();
  final _culturalSignificanceController = TextEditingController();
  final _priceController = TextEditingController();
  final _roomsController = TextEditingController();
  final _guestsController = TextEditingController();
  final _bathroomsController = TextEditingController();

  String? _selectedCategory;
  int? _selectedSiteId;
  List<dynamic> _sites = [];
  final List<PlatformFile?> _images = [null, null, null, null];

  final List<String> _categories = ['homestay', 'guest_house', 'traditional'];

  static const List<String> _allAmenities = [
    'WiFi', 'Parking', 'Hot Water', 'Air Conditioning', 'Heating',
    'Kitchen', 'Breakfast Included', 'Laundry', 'Garden', 'Terrace',
    'Mountain View', 'River View', 'TV', 'Bonfire', 'Guided Tours', 'Bicycle Rental',
  ];
  final Set<String> _selectedAmenities = {};

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _buildingHistoryController.dispose();
    _traditionalFeaturesController.dispose();
    _culturalExperiencesController.dispose();
    _culturalSignificanceController.dispose();
    _priceController.dispose();
    _roomsController.dispose();
    _guestsController.dispose();
    _bathroomsController.dispose();
    super.dispose();
  }

  Future<void> _loadSites() async {
    try {
      final response = await SitesRemoteDatasource().getSites();
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _sites = response.data as List<dynamic>;
          _sitesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _sitesLoading = false);
    }
  }

  Future<void> _pickImage(int index) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && mounted) {
      setState(() => _images[index] = result.files.first);
    }
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
      final files = _images.whereType<PlatformFile>().toList();
      final response = await HomestaysRemoteDatasource().createHomestay(
        fields: {
          'Name': _nameController.text.trim(),
          'Location': _locationController.text.trim(),
          'Description': _descriptionController.text.trim(),
          'Category': _selectedCategory,
          'PricePerNight': _priceController.text.trim(),
          'NearCulturalSiteId': _selectedSiteId,
          'NumberOfRooms': _roomsController.text.trim(),
          'MaxGuests': _guestsController.text.trim(),
          'Bathrooms': _bathroomsController.text.trim(),
          'BuildingHistory': _buildingHistoryController.text.trim(),
          'TraditionalFeatures': _traditionalFeaturesController.text.trim(),
          'CulturalExperiences': _culturalExperiencesController.text.trim(),
          'CulturalSignificance': _culturalSignificanceController.text.trim(),
          'Amenities': _selectedAmenities.join(','),
        },
        files: files,
      );

      if (response.statusCode == 200 && mounted) {
        Navigator.pop(context, true);
      }
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
        title: const Text(
          'Add Homestay',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isLoading
                ? const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : TextButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check, color: Colors.lightGreen),
              label: const Text(
                'Upload',
                style: TextStyle(
                    color: Colors.blueGrey, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('Basic Information', Icons.home_outlined, [
                _field(_nameController, 'Homestay Name'),
                _field(_locationController, 'Location',
                    hint: 'e.g. Bhaktapur, Kathmandu Valley'),
                _field(_descriptionController, 'Description',
                    lines: 4,
                    hint: 'Describe your homestay to potential guests'),
                _categoryDropdown(),
              ]),

              _section('Pricing & Capacity', Icons.payments_outlined, [
                _field(_priceController, 'Price per Night (Rs.)',
                    number: true),
                Row(children: [
                  Expanded(child: _field(_roomsController, 'Rooms', number: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_guestsController, 'Max Guests', number: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_bathroomsController, 'Bathrooms', number: true)),
                ]),
              ]),

              _section('Near Cultural Site', Icons.temple_hindu_outlined, [
                _siteSelector(),
              ]),

              _section('Cultural Heritage', Icons.auto_stories_outlined, [
                _field(_culturalSignificanceController, 'Cultural Significance',
                    lines: 3, required: false,
                    hint: 'Historical or spiritual importance of this place'),
                _field(_buildingHistoryController, 'Building History',
                    lines: 3, required: false,
                    hint: 'When and how was this building constructed?'),
                _field(_traditionalFeaturesController, 'Traditional Features',
                    lines: 3, required: false,
                    hint: 'Newari woodwork, courtyard, traditional kitchen...'),
                _field(_culturalExperiencesController, 'Cultural Experiences',
                    lines: 3, required: false,
                    hint: 'e.g. Thangka painting, Mask dance, Pottery'),
              ]),

              _section('Amenities', Icons.checklist_outlined, [
                const Text(
                  'Select everything your homestay offers',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                _amenityChips(),
              ]),

              _section('Photos', Icons.photo_library_outlined, [
                const Text(
                  'Add up to 4 photos · Tap a slot to upload',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(4, _imageBox),
                ),
              ]),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.publish),
                  label: const Text('Upload Homestay',
                      style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: Colors.grey),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _field(
      TextEditingController ctrl,
      String label, {
        int lines = 1,
        bool number = false,
        bool required = true,
        String? hint,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: lines,
        keyboardType: number
            ? const TextInputType.numberWithOptions(decimal: true)
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.greenAccent),
          ),
          filled: true,
          fillColor: const Color(0xFFFAF9F7),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        validator: required
            ? (v) => (v?.trim().isEmpty ?? true) ? '$label is required' : null
            : null,
      ),
    );
  }

  Widget _categoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedCategory,
        decoration: InputDecoration(
          labelText: 'Category',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black),
          ),
          filled: true,
          fillColor: const Color(0xFFFAF9F7),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        items: _categories
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: (val) => setState(() => _selectedCategory = val),
      ),
    );
  }

  Widget _siteSelector() {
    if (_sitesLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_sites.isEmpty) {
      return const Text('No cultural sites available.',
          style: TextStyle(color: Colors.grey));
    }
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFFAF9F7),
      ),
      child: ListView.builder(
        itemCount: _sites.length,
        itemBuilder: (_, i) {
          final site = _sites[i];
          final siteId = site['id'] as int?;
          final siteName = site['name']?.toString() ?? 'Unnamed';
          final isSelected = _selectedSiteId == siteId;

          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor:
              isSelected ? Colors.grey : Colors.grey.shade200,
              child: Icon(Icons.temple_hindu,
                  size: 16,
                  color: isSelected ? Colors.white : Colors.black),
            ),
            title: Text(
              siteName,
              style: TextStyle(
                fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black : Colors.black87,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle,
                color: Colors.blueGrey, size: 20)
                : null,
            onTap: () => setState(() => _selectedSiteId = siteId),
          );
        },
      ),
    );
  }

  Widget _amenityChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allAmenities.map((amenity) {
        final selected = _selectedAmenities.contains(amenity);
        return FilterChip(
          label: Text(amenity, style: const TextStyle(fontSize: 13)),
          selected: selected,
          onSelected: (val) => setState(() {
            val
                ? _selectedAmenities.add(amenity)
                : _selectedAmenities.remove(amenity);
          }),
          selectedColor: Colors.orange.withOpacity(0.15),
          checkmarkColor: Colors.orange,
          side: BorderSide(
              color: selected ? Colors.orange : Colors.grey.shade300),
          backgroundColor: const Color(0xFFFAF9F7),
          showCheckmark: true,
        );
      }).toList(),
    );
  }

  Widget _imageBox(int index) {
    final file = _images[index];
    final hasImage = file != null;

    return GestureDetector(
      onTap: () => _pickImage(index),
      child: Container(
        height: 110,
        width: 110,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(
            color: hasImage ? Colors.orange : Colors.grey.shade300,
            width: hasImage ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: hasImage
            ? Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.file(File(file.path!), fit: BoxFit.cover),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () =>
                    setState(() => _images[index] = null),
                child: const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close,
                      size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate,
                size: 30, color: Colors.grey[400]),
            const SizedBox(height: 4),
            Text('Photo ${index + 1}',
                style: TextStyle(
                    fontSize: 11, color: Colors.grey[400])),
          ],
        ),
      ),
    );
  }
}