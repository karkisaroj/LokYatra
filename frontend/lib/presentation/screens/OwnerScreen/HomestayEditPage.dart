import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lokyatra_frontend/data/datasources/homestays_remote_datasource.dart';
import '../../widgets/Helpers/form_helpers.dart';

class HomestayEditPage extends StatefulWidget {
  final Map<String, dynamic> homestay;
  const HomestayEditPage({super.key, required this.homestay});

  @override
  State<HomestayEditPage> createState() => _HomestayEditPageState();
}

class _HomestayEditPageState extends State<HomestayEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _name;
  late TextEditingController _location;
  late TextEditingController _description;
  late TextEditingController _price;
  late TextEditingController _rooms;
  late TextEditingController _guests;

  final List<PlatformFile?> _imageFiles = List.filled(4, null);

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.homestay['name']?.toString());
    _location = TextEditingController(text: widget.homestay['location']?.toString());
    _description = TextEditingController(text: widget.homestay['description']?.toString());
    _price = TextEditingController(text: widget.homestay['pricePerNight']?.toString());
    _rooms = TextEditingController(text: widget.homestay['numberOfRooms']?.toString());
    _guests = TextEditingController(text: widget.homestay['maxGuests']?.toString());
  }

  Future<void> _pickImage(int slotIndex) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
    );
    if (result != null && result.files.isNotEmpty && mounted) {
      final file = result.files.first;
      if (file.size > 2 * 1024 * 1024) {
        FormHelpers.showSnack(context, "File too large (max 2MB)");
        return;
      }
      setState(() {
        _imageFiles[slotIndex] = file;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles[index] = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;
    setState(() => _isLoading = true);

    final files = _imageFiles.where((f) => f != null).cast<PlatformFile>().toList();

    // Preserve old URLs for slots where no new file was picked
    final existingUrls = List<String>.from(widget.homestay['imageUrls'] ?? []);
    final finalUrls = <String>[];
    for (int i = 0; i < 4; i++) {
      if (_imageFiles[i] == null && i < existingUrls.length) {
        finalUrls.add(existingUrls[i]);
      }
    }

    try {
      final response = await HomestaysRemoteDatasource().updateHomestay(
        id: widget.homestay['id'],
        fields: {
          "Name": _name.text.trim(),
          "Location": _location.text.trim(),
          "Description": _description.text.trim(),
          "Category": widget.homestay['category'],
          "PricePerNight": _price.text.trim(),
          "NumberOfRooms": _rooms.text.trim(),
          "MaxGuests": _guests.text.trim(),
          "Bathrooms": widget.homestay['bathrooms'],
          "Amenities": (widget.homestay['amenities'] as List).join(','),
          "NearCulturalSiteId": widget.homestay['nearCulturalSiteId'],
          "BuildingHistory": widget.homestay['buildingHistory'],
          "CulturalSignificance": widget.homestay['culturalSignificance'],
          "TraditionalFeatures": widget.homestay['traditionalFeatures'],
          "CulturalExperiences": widget.homestay['culturalExperiences'],
          "ImageUrls": finalUrls, // send old URLs for unchanged slots
        },
        files: files, // only new images are uploaded
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        FormHelpers.showSnack(context, "Update failed: ${response.statusCode}");
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      FormHelpers.showSnack(context, "Error: $error");
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _description.dispose();
    _price.dispose();
    _rooms.dispose();
    _guests.dispose();
    super.dispose();
  }

  Widget _buildImageSlot(int index, List<dynamic> existingImages) {
    final file = _imageFiles[index];
    final existingUrl = (index < existingImages.length) ? existingImages[index].toString() : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (file != null)
          Stack(
            children: [
              Image.memory(file.bytes!, height: 120, width: double.infinity, fit: BoxFit.cover),
              Positioned(
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _removeImage(index),
                ),
              ),
            ],
          )
        else if (existingUrl != null)
          Image.network(existingUrl, height: 120, width: double.infinity, fit: BoxFit.cover)
        else
          Container(
            height: 120,
            width: double.infinity,
            color: Colors.grey[200],
            child: const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
          ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _pickImage(index),
          child: Text(file != null ? "Replace Image ${index + 1}" : "Add Image ${index + 1}"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> existingImages = widget.homestay['imageUrls'] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Homestay")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              FormHelpers.requiredField(_name, "Name"),
              const SizedBox(height: 12),
              FormHelpers.requiredField(_location, "Location"),
              const SizedBox(height: 12),
              FormHelpers.textArea(_description, "Description", required: true),
              const SizedBox(height: 12),
              FormHelpers.numberField(_price, "Price", required: true, decimal: true),
              const SizedBox(height: 12),
              FormHelpers.numberField(_rooms, "Rooms", required: true),
              const SizedBox(height: 12),
              FormHelpers.numberField(_guests, "Guests", required: true),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text("Images", style: TextStyle(fontWeight: FontWeight.bold)),
              for (int i = 0; i < 4; i++) ...[
                const SizedBox(height: 12),
                _buildImageSlot(i, existingImages),
              ],
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text("Update"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}