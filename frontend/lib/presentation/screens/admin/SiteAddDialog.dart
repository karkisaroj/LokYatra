import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/data/models/Site.dart';
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

  final _name       = TextEditingController();
  final _category   = TextEditingController();
  final _district   = TextEditingController();
  final _address    = TextEditingController();
  final _short      = TextEditingController();
  final _historical = TextEditingController();
  final _cultural   = TextEditingController();
  final _feeNpr     = TextEditingController();
  final _feeSaarc   = TextEditingController();
  final _openTime   = TextEditingController();
  final _closeTime  = TextEditingController();
  final _bestTime   = TextEditingController();
  bool _isUnesco = false;

  List<PlatformFile> _images = [];

  static const _brown     = Color(0xFF5C4033);
  static const _lightBrown = Color(0xFFF5EDE8);

  @override
  void dispose() {
    for (final c in [_name, _category, _district, _address, _short,
      _historical, _cultural, _feeNpr, _feeSaarc, _openTime, _closeTime, _bestTime]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
    );
    if (res == null) return;
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

  Future<void> _pickTime(TextEditingController c) async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) {
      c.text = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final fields = <String, dynamic>{
      'Name': _name.text.trim(),
      'Category': _category.text.trim(),
      'District': _district.text.trim(),
      'Address': _address.text.trim(),
      'ShortDescription': _short.text.trim(),
      if (_historical.text.trim().isNotEmpty) 'HistoricalSignificance': _historical.text.trim(),
      if (_cultural.text.trim().isNotEmpty)   'CulturalImportance': _cultural.text.trim(),
      if (_feeNpr.text.trim().isNotEmpty)     'EntryFeeNPR': double.tryParse(_feeNpr.text.trim()),
      if (_feeSaarc.text.trim().isNotEmpty)   'EntryFeeSAARC': double.tryParse(_feeSaarc.text.trim()),
      if (_openTime.text.trim().isNotEmpty)   'OpeningTime': _openTime.text.trim(),
      if (_closeTime.text.trim().isNotEmpty)  'ClosingTime': _closeTime.text.trim(),
      if (_bestTime.text.trim().isNotEmpty)   'BestTimeToVisit': _bestTime.text.trim(),
      'IsUNESCO': _isUnesco,
    };
    context.read<SitesBloc>().add(CreateSite(fields: fields, files: _images));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SitesBloc, SitesState>(
      listener: (context, state) {
        if (state is SiteCreateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Site added!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else if (state is SitesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF7F2),
        appBar: AppBar(
          title: Text('Add Cultural Site', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2D1B10),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
        ),
        body: BlocBuilder<SitesBloc, SitesState>(
          builder: (context, state) {
            final loading = state is SitesLoading;
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Section(title: 'Basic Info', icon: Icons.info_outline, children: [
                          _Field(_name, 'Site Name *', required: true),
                          _TwoColumns(
                            left: _Field(_category, 'Category *', required: true),
                            right: _Field(_district, 'District *', required: true),
                          ),
                          _Field(_address, 'Address *', required: true),
                          _Field(_short, 'Short Description *', lines: 3, required: true),
                        ]),

                        _Section(title: 'Significance', icon: Icons.auto_stories_outlined, children: [
                          _Field(_historical, 'Historical Significance', lines: 3),
                          _Field(_cultural, 'Cultural Importance', lines: 3),
                        ]),

                        _Section(title: 'Fees & Hours', icon: Icons.receipt_long_outlined, children: [
                          _TwoColumns(
                            left: _Field(_feeNpr, 'Entry Fee (NPR)', isNumber: true),
                            right: _Field(_feeSaarc, 'Entry Fee (SAARC)', isNumber: true),
                          ),
                          _TwoColumns(
                            left: _TimeField(_openTime, 'Opening Time', _pickTime),
                            right: _TimeField(_closeTime, 'Closing Time', _pickTime),
                          ),
                          _Field(_bestTime, 'Best Time to Visit'),
                        ]),

                        _Section(title: 'Settings', icon: Icons.tune_outlined, children: [
                          Container(
                            decoration: BoxDecoration(
                              color: _isUnesco ? _lightBrown : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: _isUnesco ? _brown.withValues(alpha: 0.3) : Colors.grey.shade200),
                            ),
                            child: SwitchListTile(
                              title: Text('UNESCO World Heritage Site', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14.sp)),
                              subtitle: Text('Mark this site as a UNESCO site', style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[500])),
                              value: _isUnesco,
                              onChanged: (val) => setState(() => _isUnesco = val),
                              activeThumbColor: _brown,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                            ),
                          ),
                        ]),

                        // ── Images ──────────────────────────────────────────
                        _Section(title: 'Images (max 5)', icon: Icons.photo_library_outlined, children: [
                          // Upload button
                          GestureDetector(
                            onTap: loading ? null : _pickImages,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              decoration: BoxDecoration(
                                color: _lightBrown,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: _brown.withValues(alpha: 0.3), style: BorderStyle.solid),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, size: 32.sp, color: _brown),
                                  SizedBox(height: 6.h),
                                  Text(
                                    _images.isEmpty ? 'Tap to add images' : 'Add more images (${_images.length}/5)',
                                    style: GoogleFonts.dmSans(color: _brown, fontWeight: FontWeight.w600, fontSize: 14.sp),
                                  ),
                                  Text('PNG, JPG, WEBP supported', style: GoogleFonts.dmSans(color: Colors.grey[500], fontSize: 11.sp)),
                                ],
                              ),
                            ),
                          ),

                          // Preview grid
                          if (_images.isNotEmpty) ...[
                            SizedBox(height: 14.h),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 8.w,
                                mainAxisSpacing: 8.h,
                              ),
                              itemCount: _images.length,
                              itemBuilder: (_, i) => _ImagePreviewTile(
                                file: _images[i],
                                onRemove: () => setState(() => _images.removeAt(i)),
                                label: i == 0 ? 'Cover' : null,
                              ),
                            ),
                          ],
                        ]),

                        SizedBox(height: 8.h),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: ElevatedButton(
                            onPressed: loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _brown,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                            ),
                            child: loading
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text('Submit Site', style: GoogleFonts.dmSans(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── SiteEditPage ──────────────────────────────────────────────────────────────

class SiteEditPage extends StatefulWidget {
  final CulturalSite site;
  const SiteEditPage({super.key, required this.site});

  @override
  State<SiteEditPage> createState() => _SiteEditPageState();
}

class _SiteEditPageState extends State<SiteEditPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _category;
  late final TextEditingController _district;
  late final TextEditingController _address;
  late final TextEditingController _short;
  late final TextEditingController _historical;
  late final TextEditingController _cultural;
  late final TextEditingController _feeNpr;
  late final TextEditingController _feeSaarc;
  late final TextEditingController _openTime;
  late final TextEditingController _closeTime;
  late final TextEditingController _bestTime;
  late bool _isUnesco;

  List<PlatformFile> _newImages = [];
  List<String> _existingImages = [];

  static const _brown     = Color(0xFF5C4033);
  static const _lightBrown = Color(0xFFF5EDE8);

  @override
  void initState() {
    super.initState();
    final s = widget.site;
    _name       = TextEditingController(text: s.name?.toString() ?? '');
    _category   = TextEditingController(text: s.category?.toString() ?? '');
    _district   = TextEditingController(text: s.district?.toString() ?? '');
    _address    = TextEditingController(text: s.address?.toString() ?? '');
    _short      = TextEditingController(text: s.shortDescription?.toString() ?? '');
    _historical = TextEditingController(text: s.historicalSignificance?.toString() ?? '');
    _cultural   = TextEditingController(text:s.culturalImportance?.toString() ?? '');
    _feeNpr     = TextEditingController(text: s.entryFeeNPR?.toString() ?? '');
    _feeSaarc   = TextEditingController(text: s.entryFeeSAARC?.toString() ?? '');
    _openTime   = TextEditingController(text:s.openingTime?.toString() ?? '');
    _closeTime  = TextEditingController(text: s.closingTime?.toString() ?? '');
    _bestTime   = TextEditingController(text: s.bestTimeToVisit?.toString() ?? '');
    _isUnesco   = s.isUNESCO == true;
    _existingImages = s.imageUrls;

  }

  @override
  void dispose() {
    for (final c in [_name, _category, _district, _address, _short,
      _historical, _cultural, _feeNpr, _feeSaarc, _openTime, _closeTime, _bestTime]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
    );
    if (res == null) return;
    setState(() {
      _newImages.addAll(res.files);
      if (_newImages.length > 5) {
        _newImages = _newImages.take(5).toList();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 5 new images allowed')),
        );
      }
    });
  }

  Future<void> _pickTime(TextEditingController c) async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) {
      c.text = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final fields = <String, dynamic>{
      'Name': _name.text.trim(),
      'Category': _category.text.trim(),
      'District': _district.text.trim(),
      'Address': _address.text.trim(),
      'ShortDescription': _short.text.trim(),
      if (_historical.text.trim().isNotEmpty) 'HistoricalSignificance': _historical.text.trim(),
      if (_cultural.text.trim().isNotEmpty)   'CulturalImportance': _cultural.text.trim(),
      if (_feeNpr.text.trim().isNotEmpty)     'EntryFeeNPR': double.tryParse(_feeNpr.text.trim()),
      if (_feeSaarc.text.trim().isNotEmpty)   'EntryFeeSAARC': double.tryParse(_feeSaarc.text.trim()),
      if (_openTime.text.trim().isNotEmpty)   'OpeningTime': _openTime.text.trim(),
      if (_closeTime.text.trim().isNotEmpty)  'ClosingTime': _closeTime.text.trim(),
      if (_bestTime.text.trim().isNotEmpty)   'BestTimeToVisit': _bestTime.text.trim(),
      'IsUNESCO': _isUnesco,
    };
    context.read<SitesBloc>().add(UpdateSite(
      id: widget.site.id,
      fields: fields,
      files: _newImages,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SitesBloc, SitesState>(
      listener: (context, state) {
        if (state is SiteCreateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Site updated!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else if (state is SitesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF7F2),
        appBar: AppBar(
          title: Text('Edit Site', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2D1B10),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
        ),
        body: BlocBuilder<SitesBloc, SitesState>(
          builder: (context, state) {
            final loading = state is SitesLoading;
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Section(title: 'Basic Info', icon: Icons.info_outline, children: [
                          _Field(_name, 'Site Name *', required: true),
                          _TwoColumns(
                            left: _Field(_category, 'Category *', required: true),
                            right: _Field(_district, 'District *', required: true),
                          ),
                          _Field(_address, 'Address *', required: true),
                          _Field(_short, 'Short Description *', lines: 3, required: true),
                        ]),

                        _Section(title: 'Significance', icon: Icons.auto_stories_outlined, children: [
                          _Field(_historical, 'Historical Significance', lines: 3),
                          _Field(_cultural, 'Cultural Importance', lines: 3),
                        ]),

                        _Section(title: 'Fees & Hours', icon: Icons.receipt_long_outlined, children: [
                          _TwoColumns(
                            left: _Field(_feeNpr, 'Entry Fee (NPR)', isNumber: true),
                            right: _Field(_feeSaarc, 'Entry Fee (SAARC)', isNumber: true),
                          ),
                          _TwoColumns(
                            left: _TimeField(_openTime, 'Opening Time', _pickTime),
                            right: _TimeField(_closeTime, 'Closing Time', _pickTime),
                          ),
                          _Field(_bestTime, 'Best Time to Visit'),
                        ]),

                        _Section(title: 'Settings', icon: Icons.tune_outlined, children: [
                          Container(
                            decoration: BoxDecoration(
                              color: _isUnesco ? _lightBrown : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: _isUnesco ? _brown.withValues(alpha: 0.3) : Colors.grey.shade200),
                            ),
                            child: SwitchListTile(
                              title: Text('UNESCO World Heritage Site', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14.sp)),
                              subtitle: Text('Mark this site as a UNESCO site', style: GoogleFonts.dmSans(fontSize: 12.sp, color: Colors.grey[500])),
                              value: _isUnesco,
                              onChanged: (val) => setState(() => _isUnesco = val),
                              activeThumbColor: _brown,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                            ),
                          ),
                        ]),

                        // ── Images ──────────────────────────────────────────
                        _Section(title: 'Images', icon: Icons.photo_library_outlined, children: [
                          // Existing images
                          if (_existingImages.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.cloud_done_outlined, size: 14.sp, color: Colors.grey[500]),
                                SizedBox(width: 6.w),
                                Text(
                                  'Current images (${_existingImages.length})',
                                  style: GoogleFonts.dmSans(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 8.w,
                                mainAxisSpacing: 8.h,
                              ),
                              itemCount: _existingImages.length,
                              itemBuilder: (_, i) => _ExistingImageTile(
                                url: _existingImages[i],
                                onRemove: () => setState(() => _existingImages.removeAt(i)),
                                label: i == 0 ? 'Cover' : null,
                              ),
                            ),
                            SizedBox(height: 14.h),
                            Divider(color: Colors.grey.shade200),
                            SizedBox(height: 14.h),
                          ],

                          // Add new images
                          GestureDetector(
                            onTap: loading ? null : _pickImages,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              decoration: BoxDecoration(
                                color: _lightBrown,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: _brown.withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, size: 28.sp, color: _brown),
                                  SizedBox(height: 4.h),
                                  Text(
                                    _newImages.isEmpty ? 'Add new images (replaces existing)' : 'New images: ${_newImages.length}/5',
                                    style: GoogleFonts.dmSans(color: _brown, fontWeight: FontWeight.w600, fontSize: 13.sp),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (_newImages.isNotEmpty) ...[
                            SizedBox(height: 12.h),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 8.w,
                                mainAxisSpacing: 8.h,
                              ),
                              itemCount: _newImages.length,
                              itemBuilder: (_, i) => _ImagePreviewTile(
                                file: _newImages[i],
                                onRemove: () => setState(() => _newImages.removeAt(i)),
                                label: i == 0 ? 'New Cover' : null,
                              ),
                            ),
                          ],
                        ]),

                        SizedBox(height: 8.h),

                        SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: ElevatedButton(
                            onPressed: loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _brown,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                            ),
                            child: loading
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text('Update Site', style: GoogleFonts.dmSans(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Shared form widgets ───────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _Section({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 17.sp, color: const Color(0xFF5C4033)),
            SizedBox(width: 8.w),
            Text(title, style: GoogleFonts.dmSans(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
          ]),
          SizedBox(height: 14.h),
          ...children,
        ],
      ),
    );
  }
}

class _TwoColumns extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _TwoColumns({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        SizedBox(width: 10.w),
        Expanded(child: right),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final int lines;
  final bool isNumber;
  final bool required;
  const _Field(this.ctrl, this.label, {this.lines = 1, this.isNumber = false, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: TextFormField(
        controller: ctrl,
        maxLines: lines,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : null,
        style: GoogleFonts.dmSans(fontSize: 14.sp),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[500]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFF5C4033))),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
        ),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final Future<void> Function(TextEditingController) onTap;
  const _TimeField(this.ctrl, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: TextFormField(
        controller: ctrl,
        readOnly: true,
        onTap: () => onTap(ctrl),
        style: GoogleFonts.dmSans(fontSize: 14.sp),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[500]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFF5C4033))),
          filled: true,
          fillColor: Colors.grey.shade50,
          suffixIcon: const Icon(Icons.access_time_rounded, size: 18),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
        ),
      ),
    );
  }
}

class _ImagePreviewTile extends StatelessWidget {
  final PlatformFile file;
  final VoidCallback onRemove;
  final String? label;
  const _ImagePreviewTile({required this.file, required this.onRemove, this.label});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: SizedBox.expand(
            child: kIsWeb
                ? (file.bytes != null ? Image.memory(file.bytes!, fit: BoxFit.cover) : const ColoredBox(color: Colors.grey))
                : (file.path != null ? Image.file(File(file.path!), fit: BoxFit.cover) : const ColoredBox(color: Colors.grey)),
          ),
        ),
        if (label != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 3.h),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.r), bottomRight: Radius.circular(10.r)),
              ),
              child: Text(label!, textAlign: TextAlign.center, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold)),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExistingImageTile extends StatelessWidget {
  final String url;
  final VoidCallback onRemove;
  final String? label;
  const _ExistingImageTile({required this.url, required this.onRemove, this.label});

  @override
  Widget build(BuildContext context) {
    // Import ProxyImage at top of file
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: SizedBox.expand(
            child: Image.network(url, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image))),
          ),
        ),
        if (label != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 3.h),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.r), bottomRight: Radius.circular(10.r)),
              ),
              child: Text(label!, textAlign: TextAlign.center, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold)),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}