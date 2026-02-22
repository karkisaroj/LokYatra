import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/sites/sites_state.dart';

class SiteAddPage extends StatefulWidget {
  const SiteAddPage({super.key});

  @override
  State<SiteAddPage> createState() => _SiteAddPageState();
}

class _SiteAddPageState extends State<SiteAddPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _name = TextEditingController();
  final _category = TextEditingController();
  final _district = TextEditingController();
  final _address = TextEditingController();
  final _short = TextEditingController();
  final _historical = TextEditingController();
  final _cultural = TextEditingController();
  final _feeNpr = TextEditingController();
  final _feeSaarc = TextEditingController();
  final _openTime = TextEditingController();
  final _closeTime = TextEditingController();
  final _bestTime = TextEditingController();
  bool _isUnesco = false;

  List<PlatformFile> _images = [];
  static const _brown = Color(0xFF5C4033);

  @override
  void dispose() {
    _name.dispose(); _category.dispose(); _district.dispose(); _address.dispose();
    _short.dispose(); _historical.dispose(); _cultural.dispose();
    _feeNpr.dispose(); _feeSaarc.dispose(); _openTime.dispose();
    _closeTime.dispose(); _bestTime.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
    );
    if (res != null) {
      setState(() {
        _images.addAll(res.files);
        if (_images.length > 5) {
          _images = _images.take(5).toList();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maximum 5 images allowed')),
          );
        }
      });
    }
  }

  void _removeImage(int index) => setState(() => _images.removeAt(index));

  Future<void> _pickTime(TextEditingController c) async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) {
      c.text = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final fields = {
      'Name': _name.text.trim(),
      'Category': _category.text.trim(),
      'District': _district.text.trim(),
      'Address': _address.text.trim(),
      'ShortDescription': _short.text.trim(),
      'HistoricalSignificance': _historical.text.trim().isEmpty ? null : _historical.text.trim(),
      'CulturalImportance': _cultural.text.trim().isEmpty ? null : _cultural.text.trim(),
      'EntryFeeNPR': double.tryParse(_feeNpr.text.trim()),
      'EntryFeeSAARC': double.tryParse(_feeSaarc.text.trim()),
      'OpeningTime': _openTime.text.trim().isEmpty ? null : _openTime.text.trim(),
      'ClosingTime': _closeTime.text.trim().isEmpty ? null : _closeTime.text.trim(),
      'BestTimeToVisit': _bestTime.text.trim().isEmpty ? null : _bestTime.text.trim(),
      'IsUNESCO': _isUnesco,
    };
    fields.removeWhere((key, value) => value == null);

    context.read<SitesBloc>().add(CreateSite(fields: fields, files: _images));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SitesBloc, SitesState>(
      listener: (context, state) {
        if (state is SiteCreateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Site added successfully'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else if (state is SitesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Cultural Site', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: BlocBuilder<SitesBloc, SitesState>(
              builder: (context, state) {
                final loading = state is SitesLoading;
                return SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection('Basic Info', Icons.info_outline, [
                          _buildTextField(_name, 'Site Name', required: true),
                          Row(children: [
                            Expanded(child: _buildTextField(_category, 'Category', required: true)),
                            SizedBox(width: 12.w),
                            Expanded(child: _buildTextField(_district, 'District', required: true)),
                          ]),
                          _buildTextField(_address, 'Address', required: true),
                          _buildTextField(_short, 'Short Description', lines: 3, required: true),
                        ]),

                        _buildSection('Details', Icons.description_outlined, [
                          _buildTextField(_historical, 'Historical Significance', lines: 3),
                          _buildTextField(_cultural, 'Cultural Importance', lines: 3),
                        ]),

                        _buildSection('Fees & Times', Icons.attach_money, [
                          Row(children: [
                            Expanded(child: _buildTextField(_feeNpr, 'Fee (NPR)', isNumber: true)),
                            SizedBox(width: 12.w),
                            Expanded(child: _buildTextField(_feeSaarc, 'Fee (SAARC)', isNumber: true)),
                          ]),
                          SizedBox(height: 12.h),
                          Row(children: [
                            Expanded(child: _buildTimeField(_openTime, 'Opening Time')),
                            SizedBox(width: 12.w),
                            Expanded(child: _buildTimeField(_closeTime, 'Closing Time')),
                          ]),
                          SizedBox(height: 12.h),
                          _buildTextField(_bestTime, 'Best Time to Visit'),
                        ]),

                        _buildSection('Settings', Icons.settings_outlined, [
                          SwitchListTile(
                            title: Text('UNESCO Site', style: GoogleFonts.dmSans()),
                            value: _isUnesco,
                            onChanged: (val) => setState(() => _isUnesco = val),
                            activeColor: _brown,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ]),

                        _buildSection('Images', Icons.image_outlined, [
                          ElevatedButton.icon(
                            onPressed: loading ? null : _pickImages,
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text('Add Images'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _brown,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          if (_images.isNotEmpty)
                            Wrap(
                              spacing: 12.w,
                              runSpacing: 12.h,
                              children: _images.asMap().entries.map((e) => _buildImageChip(e.key, e.value)).toList(),
                            ),
                        ]),

                        SizedBox(height: 24.h),
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _brown,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                            child: loading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text('Submit Site', style: GoogleFonts.dmSans(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 20.sp, color: _brown),
            SizedBox(width: 8.w),
            Text(title, style: GoogleFonts.dmSans(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          ]),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, {int lines = 1, bool isNumber = false, bool required = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: ctrl,
        maxLines: lines,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : null,
        style: GoogleFonts.dmSans(fontSize: 14.sp),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        ),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null : null,
      ),
    );
  }

  Widget _buildTimeField(TextEditingController ctrl, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: ctrl,
        readOnly: true,
        onTap: () => _pickTime(ctrl),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          suffixIcon: const Icon(Icons.access_time, size: 20),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildImageChip(int index, PlatformFile file) {
    return Stack(
      children: [
        Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: kIsWeb
                ? (file.bytes != null ? Image.memory(file.bytes!, fit: BoxFit.cover) : const Icon(Icons.image))
                : (file.path != null ? Image.file(File(file.path!), fit: BoxFit.cover) : const Icon(Icons.image)),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
