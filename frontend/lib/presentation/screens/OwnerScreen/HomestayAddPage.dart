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

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _roomsController = TextEditingController();
  final _guestsController = TextEditingController();
  final _bathroomsController = TextEditingController();

  String? _selectedCategory;
  int? _selectedSiteId;

  List<dynamic> _sites = [];
  final List<PlatformFile> _imageFiles = [];

  final List<String> _categories = [
    'homestay',
    'guest_house',
    'traditional'
  ];

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  Future<void> _loadSites() async {
    final response = await SitesRemoteDatasource().getSites();
    if (response.statusCode == 200) {
      setState(() => _sites = response.data);
    }
  }

  Future<void> _pickImage() async {
    if (_imageFiles.length == 4) {
      FormHelpers.showSnack(context, "Maximum 4 images allowed");
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.image,
    );

    if (result != null) {
      setState(() => _imageFiles.add(result.files.first));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      FormHelpers.showSnack(context, "Select category");
      return;
    }

    if (_selectedSiteId == null) {
      FormHelpers.showSnack(context, "Select nearby heritage site");
      return;
    }

    if (_imageFiles.isEmpty) {
      FormHelpers.showSnack(context, "Upload at least 1 image");
      return;
    }

    setState(() => _isLoading = true);

    final response = await HomestaysRemoteDatasource().createHomestay(
      fields: {
        "Name": _nameController.text.trim(),
        "Location": _locationController.text.trim(),
        "Description": _descriptionController.text.trim(),
        "Category": _selectedCategory,
        "PricePerNight": _priceController.text.trim(),
        "NearCulturalSiteId": _selectedSiteId,
        "NumberOfRooms": _roomsController.text.trim(),
        "MaxGuests": _guestsController.text.trim(),
        "Bathrooms": _bathroomsController.text.trim(),
      },
      files: _imageFiles,
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      FormHelpers.showSnack(context, "Failed: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Homestay")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              FormHelpers.sectionTitle("Basic Info"),
              const SizedBox(height: 12),

              FormHelpers.requiredField(_nameController, "Name"),
              const SizedBox(height: 12),

              FormHelpers.requiredField(_locationController, "Location"),
              const SizedBox(height: 12),

              FormHelpers.textArea(_descriptionController, "Description", required: true),
              const SizedBox(height: 12),

              FormHelpers.numberField(_priceController, "Price/Night", required: true, decimal: true),
              const SizedBox(height: 12),

              FormHelpers.numberField(_roomsController, "Rooms", required: true),
              const SizedBox(height: 12),

              FormHelpers.numberField(_guestsController, "Guests", required: true),
              const SizedBox(height: 12),

              FormHelpers.numberField(_bathroomsController, "Bathrooms", required: true),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: _categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Category *",
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<int>(
                initialValue: _selectedSiteId,
                items: _sites.map<DropdownMenuItem<int>>((site) =>
                    DropdownMenuItem<int>(value: site['id'], child: Text(site['name']))).toList(),
                onChanged: (v) => setState(() => _selectedSiteId = v),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Near Site *",
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Add Image"),
              ),

              const SizedBox(height: 12),

              // Show picked images preview
              if (_imageFiles.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imageFiles.length,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Image.memory(
                          _imageFiles[i].bytes!,
                          height: 120,
                          width: 160,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 24),

              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text("Create"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}