import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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

  // ── Text controllers ────────────────────────────────────────────────
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

  // ── Dropdowns ───────────────────────────────────────────────────────
  String? _selectedCategory;
  int? _selectedSiteId;

  final List<String> _categories = ['homestay', 'guest_house', 'traditional'];

  // ── Sites ───────────────────────────────────────────────────────────
  List<dynamic> _sites = [];

  // ── Amenities ───────────────────────────────────────────────────────
  static const List<String> _allAmenities = [
    'WiFi',
    'Parking',
    'Hot Water',
    'Air Conditioning',
    'Heating',
    'Kitchen',
    'Breakfast Included',
    'Laundry',
    'Garden',
    'Terrace',
    'Mountain View',
    'River View',
    'TV',
    'Bonfire',
    'Guided Tours',
    'Bicycle Rental',
  ];
  late Set<String> _selectedAmenities;

  // ── Images ──────────────────────────────────────────────────────────
  // We keep up to 4 slots: each slot has either an existing URL or a new file
  late List<String> _existingImages;   // '' means empty
  final List<PlatformFile?> _newImages = [null, null, null, null];

  // ── Visibility toggle ────────────────────────────────────────────────
  late bool _isVisible;

  @override
  void initState() {
    super.initState();
    final h = widget.homestay;

    _name                 = TextEditingController(text: h.name);
    _location             = TextEditingController(text: h.location);
    _description          = TextEditingController(text: h.description);
    _price                = TextEditingController(text: h.pricePerNight.toStringAsFixed(0));
    _rooms                = TextEditingController(text: h.numberOfRooms.toString());
    _guests               = TextEditingController(text: h.maxGuests.toString());
    _bathrooms            = TextEditingController(text: h.bathrooms.toString());
    _buildingHistory      = TextEditingController(text: h.buildingHistory ?? '');
    _traditionalFeatures  = TextEditingController(text: h.traditionalFeatures ?? '');
    _culturalExperiences  = TextEditingController(text: h.culturalExperiences.join(', '));
    _culturalSignificance = TextEditingController(text: h.culturalSignificance ?? '');

    _selectedCategory = h.category;
    _selectedSiteId   = h.nearCulturalSite?.id;
    _isVisible        = h.isVisible;

    // Normalize amenity names for matching (case-insensitive)
    _selectedAmenities = h.amenities
        .map((a) => a.trim())
        .where((a) => a.isNotEmpty)
        .toSet();

    // Pre-fill up to 4 existing image slots
    _existingImages = List.filled(4, '');
    for (int i = 0; i < 4 && i < h.imageUrls.length; i++) {
      _existingImages[i] = h.imageUrls[i];
    }

    _loadSites();
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
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _newImages[index] = result.files.first;
        _existingImages[index] = ''; // replaced
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _newImages[index] = null;
      _existingImages[index] = '';
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final fields = {
      'Name':                _name.text.trim(),
      'Location':            _location.text.trim(),
      'Description':         _description.text.trim(),
      'PricePerNight':       _price.text.trim(),
      'NumberOfRooms':       _rooms.text.trim(),
      'MaxGuests':           _guests.text.trim(),
      'Bathrooms':           _bathrooms.text.trim(),
      'BuildingHistory':     _buildingHistory.text.trim(),
      'TraditionalFeatures': _traditionalFeatures.text.trim(),
      'CulturalExperiences': _culturalExperiences.text.trim(),
      'CulturalSignificance':_culturalSignificance.text.trim(),
      'Amenities':           _selectedAmenities.join(','),
      'IsVisible':           _isVisible.toString(),
      if (_selectedCategory != null) 'Category': _selectedCategory!,
      if (_selectedSiteId != null)   'NearCulturalSiteId': _selectedSiteId.toString(),
    };

    final newFiles = _newImages.whereType<PlatformFile>().toList();

    try {
      final response = await HomestaysRemoteDatasource().updateHomestay(
        id: widget.homestay.id,
        fields: fields,
        files: newFiles,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) Navigator.pop(context, true);
      } else {
        _showSnack('Update failed: ${response.statusMessage}');
      }
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── UI helpers ───────────────────────────────────────────────────────

  Widget _field(
      TextEditingController ctrl,
      String label, {
        int lines = 1,
        bool number = false,
        bool required = true,
        String? hint,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        maxLines: lines,
        keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: required
            ? (v) => (v?.trim().isEmpty ?? true) ? '$label is required' : null
            : null,
      ),
    );
  }

  Widget _sectionHeader(String title, {String? subtitle}) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (subtitle != null)
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    ),
  );

  Widget _imageSlot(int index) {
    final newFile = _newImages[index];
    final existing = _existingImages[index];
    final hasContent = newFile != null || existing.isNotEmpty;

    return GestureDetector(
      onTap: () => _pickImage(index),
      child: Container(
        height: 110,
        width: 110,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(
            color: hasContent ? Colors.orange : Colors.grey.shade300,
            width: hasContent ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: newFile != null
                  ? Image.file(File(newFile.path!), fit: BoxFit.cover)
                  : existing.isNotEmpty
                  ? ProxyImage(
                imageUrl: existing,
                width: double.infinity,
                height: double.infinity,
                borderRadiusValue: 0,
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate,
                      size: 32, color: Colors.grey[400]),
                  const SizedBox(height: 4),
                  Text('Slot ${index + 1}',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[400])),
                ],
              ),
            ),
            if (hasContent)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            if (!hasContent)
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Center(
                  child: Text('Tap to add',
                      style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _amenityCheckboxes() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: _allAmenities.map((amenity) {
        final selected = _selectedAmenities.any(
              (s) => s.toLowerCase() == amenity.toLowerCase(),
        );
        return FilterChip(
          label: Text(amenity, style: const TextStyle(fontSize: 13)),
          selected: selected,
          onSelected: (val) {
            setState(() {
              if (val) {
                _selectedAmenities.add(amenity);
              } else {
                _selectedAmenities.removeWhere(
                      (s) => s.toLowerCase() == amenity.toLowerCase(),
                );
              }
            });
          },
          selectedColor: Colors.orange.withOpacity(0.2),
          checkmarkColor: Colors.orange,
          side: BorderSide(
            color: selected ? Colors.orange : Colors.grey.shade300,
          ),
          showCheckmark: true,
        );
      }).toList(),
    );
  }

  Widget _siteSelector() {
    if (_sitesLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_sites.isEmpty) {
      return const Text('No sites available.',
          style: TextStyle(color: Colors.grey));
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
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
              isSelected ? Colors.orange : Colors.grey.shade200,
              child: Icon(
                Icons.temple_hindu,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
            title: Text(siteName,
                style: TextStyle(
                  fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.orange : Colors.black87,
                )),
            trailing: isSelected
                ? const Icon(Icons.check_circle,
                color: Colors.orange, size: 20)
                : null,
            onTap: () => setState(() => _selectedSiteId = siteId),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _description.dispose();
    _price.dispose();
    _rooms.dispose();
    _guests.dispose();
    _bathrooms.dispose();
    _buildingHistory.dispose();
    _traditionalFeatures.dispose();
    _culturalExperiences.dispose();
    _culturalSignificance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Homestay'),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _submit,
            icon: const Icon(Icons.save, color: Colors.orange),
            label: const Text('Save', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Visibility Toggle ─────────────────────────────────────
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: SwitchListTile(
                  title: const Text('Listing Active',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(_isVisible
                      ? 'Visible to guests'
                      : 'Hidden from guests'),
                  value: _isVisible,
                  activeColor: Colors.orange,
                  onChanged: (val) => setState(() => _isVisible = val),
                ),
              ),

              // ── Basic Info ────────────────────────────────────────────
              _sectionHeader('Basic Information'),
              _field(_name, 'Name'),
              _field(_location, 'Location'),
              _field(_description, 'Description', lines: 4),

              // ── Category ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: _categories
                      .map((c) =>
                      DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _selectedCategory = val),
                ),
              ),

              // ── Pricing & Capacity ────────────────────────────────────
              _sectionHeader('Pricing & Capacity'),
              _field(_price, 'Price per Night (Rs.)',
                  number: true),
              Row(
                children: [
                  Expanded(child: _field(_rooms, 'Rooms', number: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_guests, 'Max Guests', number: true)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _field(_bathrooms, 'Bathrooms', number: true)),
                ],
              ),

              // ── Near Cultural Site ────────────────────────────────────
              _sectionHeader('Near Cultural Site',
                  subtitle: 'Tap a site to select it'),
              _siteSelector(),
              const SizedBox(height: 14),

              // ── Cultural Heritage ─────────────────────────────────────
              _sectionHeader('Cultural Heritage'),
              _field(_culturalSignificance, 'Cultural Significance',
                  lines: 3, required: false),
              _field(_buildingHistory, 'Building History',
                  lines: 3, required: false),
              _field(_traditionalFeatures, 'Traditional Features',
                  lines: 3, required: false),
              _field(
                _culturalExperiences,
                'Cultural Experiences',
                lines: 3,
                required: false,
                hint: 'e.g. Thangka painting, Mask dance, Pottery',
              ),

              // ── Amenities ─────────────────────────────────────────────
              _sectionHeader('Amenities',
                  subtitle: 'Tap to select what your homestay offers'),
              _amenityCheckboxes(),
              const SizedBox(height: 16),

              // ── Images ───────────────────────────────────────────────
              _sectionHeader('Images',
                  subtitle: 'Tap a slot to change · Tap ✕ to remove'),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(4, _imageSlot),
              ),
              const SizedBox(height: 32),

              // ── Save Button ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes',
                      style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}