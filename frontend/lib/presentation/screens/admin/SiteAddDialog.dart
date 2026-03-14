import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final _formKey    = GlobalKey<FormState>();
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
  bool _isUnesco    = false;
  List<PlatformFile> _images = [];

  static const _brown      = Color(0xFF5C4033);
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
      allowMultiple: true, withData: true,
      type: FileType.custom, allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
    );
    if (res == null) return;
    setState(() {
      _images.addAll(res.files);
      if (_images.length > 5) {
        _images = _images.take(5).toList();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum 5 images allowed')));
      }
    });
  }

  Future<void> _pickTime(TextEditingController c) async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) c.text = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<SitesBloc>().add(CreateSite(fields: {
      'Name': _name.text.trim(), 'Category': _category.text.trim(),
      'District': _district.text.trim(), 'Address': _address.text.trim(),
      'ShortDescription': _short.text.trim(),
      if (_historical.text.trim().isNotEmpty) 'HistoricalSignificance': _historical.text.trim(),
      if (_cultural.text.trim().isNotEmpty)   'CulturalImportance': _cultural.text.trim(),
      if (_feeNpr.text.trim().isNotEmpty)     'EntryFeeNPR': double.tryParse(_feeNpr.text.trim()),
      if (_feeSaarc.text.trim().isNotEmpty)   'EntryFeeSAARC': double.tryParse(_feeSaarc.text.trim()),
      if (_openTime.text.trim().isNotEmpty)   'OpeningTime': _openTime.text.trim(),
      if (_closeTime.text.trim().isNotEmpty)  'ClosingTime': _closeTime.text.trim(),
      if (_bestTime.text.trim().isNotEmpty)   'BestTimeToVisit': _bestTime.text.trim(),
      'IsUNESCO': _isUnesco,
    }, files: _images));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SitesBloc, SitesState>(
      listener: (context, state) {
        if (state is SiteCreateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Site added!'), backgroundColor: Colors.green));
          Navigator.pop(context, true);
        } else if (state is SitesError) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF7F2),
        appBar: AppBar(
          title: Text('Add Cultural Site',
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
          backgroundColor: Colors.white, foregroundColor: const Color(0xFF2D1B10), elevation: 0,
          bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: Colors.grey.shade200)),
        ),
        body: BlocBuilder<SitesBloc, SitesState>(
          builder: (context, state) {
            final loading = state is SitesLoading;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Form(key: _formKey, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Section(title: 'Basic Info', icon: Icons.info_outline, children: [
                      _Field(_name,    'Site Name *',          required: true),
                      _TwoCol(left: _Field(_category, 'Category *', required: true),
                          right: _Field(_district, 'District *', required: true)),
                      _Field(_address, 'Address *',            required: true),
                      _Field(_short,   'Short Description *',  lines: 3, required: true),
                    ]),
                    _Section(title: 'Significance', icon: Icons.auto_stories_outlined, children: [
                      _Field(_historical, 'Historical Significance', lines: 3),
                      _Field(_cultural,   'Cultural Importance',     lines: 3),
                    ]),
                    _Section(title: 'Fees & Hours', icon: Icons.receipt_long_outlined, children: [
                      _TwoCol(left: _Field(_feeNpr,   'Entry Fee (NPR)',   isNumber: true),
                          right: _Field(_feeSaarc, 'Entry Fee (SAARC)', isNumber: true)),
                      _TwoCol(left: _TimeField(_openTime,  'Opening Time', _pickTime),
                          right: _TimeField(_closeTime, 'Closing Time', _pickTime)),
                      _Field(_bestTime, 'Best Time to Visit'),
                    ]),
                    _Section(title: 'Settings', icon: Icons.tune_outlined, children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _isUnesco ? _lightBrown : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _isUnesco ? _brown.withValues(alpha: 0.3) : Colors.grey.shade200),
                        ),
                        child: SwitchListTile(
                          title: Text('UNESCO World Heritage Site', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Text('Mark this site as a UNESCO site', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey[500])),
                          value: _isUnesco,
                          onChanged: (val) => setState(() => _isUnesco = val),
                          activeThumbColor: _brown,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),
                      ),
                    ]),
                    _Section(title: 'Images (max 5)', icon: Icons.photo_library_outlined, children: [
                      GestureDetector(
                        onTap: loading ? null : _pickImages,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _lightBrown, borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _brown.withValues(alpha: 0.3)),
                          ),
                          child: Column(children: [
                            const Icon(Icons.add_photo_alternate_outlined, size: 32, color: _brown),
                            const SizedBox(height: 6),
                            Text(_images.isEmpty ? 'Tap to add images' : 'Add more images (${_images.length}/5)',
                                style: GoogleFonts.dmSans(color: _brown, fontWeight: FontWeight.w600, fontSize: 14)),
                            Text('PNG, JPG, WEBP supported', style: GoogleFonts.dmSans(color: Colors.grey[500], fontSize: 11)),
                          ]),
                        ),
                      ),
                      if (_images.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8),
                          itemCount: _images.length,
                          itemBuilder: (_, i) => _ImagePreviewTile(
                            file: _images[i],
                            onRemove: () => setState(() => _images.removeAt(i)),
                            label: i == 0 ? 'Cover' : null,
                          ),
                        ),
                      ],
                    ]),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton(
                        onPressed: loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brown, foregroundColor: Colors.white, elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: loading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Submit Site', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                )),
              )),
            );
          },
        ),
      ),
    );
  }
}


class SiteEditPage extends StatefulWidget {
  final CulturalSite site;
  const SiteEditPage({super.key, required this.site});
  @override
  State<SiteEditPage> createState() => _SiteEditPageState();
}

class _SiteEditPageState extends State<SiteEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name, _category, _district, _address, _short,
      _historical, _cultural, _feeNpr, _feeSaarc, _openTime, _closeTime, _bestTime;
  late bool _isUnesco;
  List<PlatformFile> _newImages    = [];
  List<String>       _existingImages = [];

  static const _brown      = Color(0xFF5C4033);
  static const _lightBrown = Color(0xFFF5EDE8);

  @override
  void initState() {
    super.initState();
    final s  = widget.site;
    _name       = TextEditingController(text: s.name ?? '');
    _category   = TextEditingController(text: s.category ?? '');
    _district   = TextEditingController(text: s.district ?? '');
    _address    = TextEditingController(text: s.address ?? '');
    _short      = TextEditingController(text: s.shortDescription ?? '');
    _historical = TextEditingController(text: s.historicalSignificance ?? '');
    _cultural   = TextEditingController(text: s.culturalImportance ?? '');
    _feeNpr     = TextEditingController(text: s.entryFeeNPR?.toString() ?? '');
    _feeSaarc   = TextEditingController(text: s.entryFeeSAARC?.toString() ?? '');
    _openTime   = TextEditingController(text: s.openingTime ?? '');
    _closeTime  = TextEditingController(text: s.closingTime ?? '');
    _bestTime   = TextEditingController(text: s.bestTimeToVisit ?? '');
    _isUnesco   = s.isUNESCO;
    _existingImages = List<String>.from(s.imageUrls);
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
      allowMultiple: true, withData: true,
      type: FileType.custom, allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
    );
    if (res == null) return;
    setState(() {
      _newImages.addAll(res.files);
      if (_newImages.length > 5) {
        _newImages = _newImages.take(5).toList();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum 5 new images allowed')));
      }
    });
  }

  Future<void> _pickTime(TextEditingController c) async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) c.text = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<SitesBloc>().add(UpdateSite(
      id: widget.site.id,
      fields: {
        'Name': _name.text.trim(), 'Category': _category.text.trim(),
        'District': _district.text.trim(), 'Address': _address.text.trim(),
        'ShortDescription': _short.text.trim(),
        if (_historical.text.trim().isNotEmpty) 'HistoricalSignificance': _historical.text.trim(),
        if (_cultural.text.trim().isNotEmpty)   'CulturalImportance': _cultural.text.trim(),
        if (_feeNpr.text.trim().isNotEmpty)     'EntryFeeNPR': double.tryParse(_feeNpr.text.trim()),
        if (_feeSaarc.text.trim().isNotEmpty)   'EntryFeeSAARC': double.tryParse(_feeSaarc.text.trim()),
        if (_openTime.text.trim().isNotEmpty)   'OpeningTime': _openTime.text.trim(),
        if (_closeTime.text.trim().isNotEmpty)  'ClosingTime': _closeTime.text.trim(),
        if (_bestTime.text.trim().isNotEmpty)   'BestTimeToVisit': _bestTime.text.trim(),
        'IsUNESCO': _isUnesco,
      },
      files: _newImages,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SitesBloc, SitesState>(
      listener: (context, state) {
        if (state is SiteCreateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Site updated!'), backgroundColor: Colors.green));
          Navigator.pop(context, true);
        } else if (state is SitesError) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF7F2),
        appBar: AppBar(
          title: Text('Edit Site',
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
          backgroundColor: Colors.white, foregroundColor: const Color(0xFF2D1B10), elevation: 0,
          bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: Colors.grey.shade200)),
        ),
        body: BlocBuilder<SitesBloc, SitesState>(
          builder: (context, state) {
            final loading = state is SitesLoading;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _Section(title: 'Basic Info', icon: Icons.info_outline, children: [
                    _Field(_name, 'Site Name *', required: true),
                    _TwoCol(left: _Field(_category, 'Category *', required: true),
                        right: _Field(_district, 'District *', required: true)),
                    _Field(_address, 'Address *', required: true),
                    _Field(_short, 'Short Description *', lines: 3, required: true),
                  ]),
                  _Section(title: 'Significance', icon: Icons.auto_stories_outlined, children: [
                    _Field(_historical, 'Historical Significance', lines: 3),
                    _Field(_cultural,   'Cultural Importance', lines: 3),
                  ]),
                  _Section(title: 'Fees & Hours', icon: Icons.receipt_long_outlined, children: [
                    _TwoCol(left: _Field(_feeNpr, 'Entry Fee (NPR)', isNumber: true),
                        right: _Field(_feeSaarc, 'Entry Fee (SAARC)', isNumber: true)),
                    _TwoCol(left: _TimeField(_openTime, 'Opening Time', _pickTime),
                        right: _TimeField(_closeTime, 'Closing Time', _pickTime)),
                    _Field(_bestTime, 'Best Time to Visit'),
                  ]),
                  _Section(title: 'Settings', icon: Icons.tune_outlined, children: [
                    Container(
                      decoration: BoxDecoration(
                        color: _isUnesco ? _lightBrown : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _isUnesco ? _brown.withValues(alpha: 0.3) : Colors.grey.shade200),
                      ),
                      child: SwitchListTile(
                        title: Text('UNESCO World Heritage Site', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text('Mark this site as a UNESCO site', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey[500])),
                        value: _isUnesco,
                        onChanged: (val) => setState(() => _isUnesco = val),
                        activeThumbColor: _brown,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                    ),
                  ]),
                  _Section(title: 'Images', icon: Icons.photo_library_outlined, children: [
                    if (_existingImages.isNotEmpty) ...[
                      Row(children: [
                        Icon(Icons.cloud_done_outlined, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 6),
                        Text('Current images (${_existingImages.length})',
                            style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600])),
                      ]),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8),
                        itemCount: _existingImages.length,
                        itemBuilder: (_, i) => _ExistingImageTile(
                          url: _existingImages[i],
                          onRemove: () => setState(() => _existingImages.removeAt(i)),
                          label: i == 0 ? 'Cover' : null,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Divider(color: Colors.grey.shade200),
                      const SizedBox(height: 14),
                    ],
                    GestureDetector(
                      onTap: loading ? null : _pickImages,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _lightBrown, borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _brown.withValues(alpha: 0.3)),
                        ),
                        child: Column(children: [
                          const Icon(Icons.add_photo_alternate_outlined, size: 28, color: _brown),
                          const SizedBox(height: 4),
                          Text(_newImages.isEmpty ? 'Add new images (replaces existing)' : 'New images: ${_newImages.length}/5',
                              style: GoogleFonts.dmSans(color: _brown, fontWeight: FontWeight.w600, fontSize: 13)),
                        ]),
                      ),
                    ),
                    if (_newImages.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8),
                        itemCount: _newImages.length,
                        itemBuilder: (_, i) => _ImagePreviewTile(
                          file: _newImages[i],
                          onRemove: () => setState(() => _newImages.removeAt(i)),
                          label: i == 0 ? 'New Cover' : null,
                        ),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brown, foregroundColor: Colors.white, elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: loading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Update Site', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ])),
              )),
            );
          },
        ),
      ),
    );
  }
}


class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _Section({required this.title, required this.icon, required this.children});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade100),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 17, color: const Color(0xFF5C4033)),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF2D1B10))),
      ]),
      const SizedBox(height: 14),
      ...children,
    ]),
  );
}

class _TwoCol extends StatelessWidget {
  final Widget left, right;
  const _TwoCol({required this.left, required this.right});
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: left), const SizedBox(width: 10), Expanded(child: right),
  ]);
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final int lines;
  final bool isNumber, required;
  const _Field(this.ctrl, this.label, {this.lines = 1, this.isNumber = false, this.required = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      controller: ctrl, maxLines: lines,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : null,
      style: GoogleFonts.dmSans(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[500]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF5C4033))),
        filled: true, fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      ),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
    ),
  );
}

class _TimeField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final Future<void> Function(TextEditingController) onTap;
  const _TimeField(this.ctrl, this.label, this.onTap);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      controller: ctrl, readOnly: true, onTap: () => onTap(ctrl),
      style: GoogleFonts.dmSans(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.dmSans(fontSize: 13, color: Colors.grey[500]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF5C4033))),
        filled: true, fillColor: Colors.grey.shade50,
        suffixIcon: const Icon(Icons.access_time_rounded, size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      ),
    ),
  );
}

class _ImagePreviewTile extends StatelessWidget {
  final PlatformFile file;
  final VoidCallback onRemove;
  final String? label;
  const _ImagePreviewTile({required this.file, required this.onRemove, this.label});
  @override
  Widget build(BuildContext context) => Stack(children: [
    ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox.expand(
        child: kIsWeb
            ? (file.bytes != null ? Image.memory(file.bytes!, fit: BoxFit.cover) : const ColoredBox(color: Colors.grey))
            : (file.path != null ? Image.file(File(file.path!), fit: BoxFit.cover) : const ColoredBox(color: Colors.grey)),
      ),
    ),
    if (label != null)
      Positioned(bottom: 0, left: 0, right: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 3),
          decoration: const BoxDecoration(color: Colors.black54,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10))),
          child: Text(label!, textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
        ),
      ),
    Positioned(top: 4, right: 4,
      child: GestureDetector(onTap: onRemove,
        child: Container(padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
            child: const Icon(Icons.close, size: 12, color: Colors.white)),
      ),
    ),
  ]);
}

class _ExistingImageTile extends StatelessWidget {
  final String url;
  final VoidCallback onRemove;
  final String? label;
  const _ExistingImageTile({required this.url, required this.onRemove, this.label});
  @override
  Widget build(BuildContext context) => Stack(children: [
    ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox.expand(
        child: Image.network(url, fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image))),
      ),
    ),
    if (label != null)
      Positioned(bottom: 0, left: 0, right: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 3),
          decoration: const BoxDecoration(color: Colors.black54,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10))),
          child: Text(label!, textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
        ),
      ),
    Positioned(top: 4, right: 4,
      child: GestureDetector(onTap: onRemove,
        child: Container(padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
            child: const Icon(Icons.close, size: 12, color: Colors.white)),
      ),
    ),
  ]);
}