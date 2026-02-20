import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/stories/story_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/stories/story_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/stories/story_state.dart';

// Story type options for the dropdown
const _storyTypes = [
  'Legend',
  'Myth',
  'Folk Tale',
  'Historical Narrative',
  'Cultural Tradition',
  'Religious Story',
  'Origin Story',
  'Moral Tale',
  'Epic',
  'Other',
];

class StoryAddDialog extends StatefulWidget {
  final int siteId;
  const StoryAddDialog({super.key, required this.siteId});

  @override
  State<StoryAddDialog> createState() => _StoryAddDialogState();
}

class _StoryAddDialogState extends State<StoryAddDialog> {
  static const _dark    = Color(0xFF1A1A2E);
  static const _accent  = Color(0xFF3D5A80);
  static const _border  = Color(0xFFDDDDDD);
  static const _bg      = Color(0xFFF8F8F8);

  final _formKey  = GlobalKey<FormState>();
  final _title    = TextEditingController();
  final _readMin  = TextEditingController(text: '5');
  final _full     = TextEditingController();
  final _hist     = TextEditingController();
  final _cult     = TextEditingController();
  String? _selectedType;
  List<PlatformFile> _files = [];

  @override
  void dispose() {
    _title.dispose();
    _readMin.dispose();
    _full.dispose();
    _hist.dispose();
    _cult.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
    );
    if (res != null) setState(() => _files = res.files.take(3).toList());
  }

  void _removeFile(int index) => setState(() => _files.removeAt(index));

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final fields = {
      'CulturalSiteId': widget.siteId,
      'Title': _title.text.trim(),
      'StoryType': _selectedType ?? '',
      'EstimatedReadTimeMinutes': int.tryParse(_readMin.text.trim()) ?? 5,
      'FullContent': _full.text.trim(),
      'HistoricalContext': _hist.text.trim().isEmpty ? null : _hist.text.trim(),
      'CulturalSignificance': _cult.text.trim().isEmpty ? null : _cult.text.trim(),
    };
    context.read<StoryBloc>().add(CreateStory(fields: fields, files: _files));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoryBloc, StoryState>(
      listener: (context, state) {
        if (state is StoryCreateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Story added successfully',
                  style: GoogleFonts.dmSans()),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        }
        if (state is StoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: GoogleFonts.dmSans()),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final loading = state is StoryLoading;
        final isWide  = MediaQuery.of(context).size.width > 700;

        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r)),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isWide ? 60.w : 16.w,
            vertical:   32.h,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ──────────────────────────────────────────
                _Header(onClose: () => Navigator.pop(context, false)),

                // ── Scrollable form ──────────────────────────────────
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 8.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Basic info section
                          _SectionLabel('Basic Information'),
                          SizedBox(height: 10.h),

                          // Title + Read time row
                          isWide
                              ? Row(children: [
                            Expanded(
                                flex: 3,
                                child: _InputField(
                                  controller: _title,
                                  label: 'Story Title',
                                  required: true,
                                )),
                            SizedBox(width: 12.w),
                            Expanded(
                                child: _InputField(
                                  controller: _readMin,
                                  label: 'Read Time (min)',
                                  required: true,
                                  inputType: TextInputType.number,
                                )),
                          ])
                              : Column(children: [
                            _InputField(
                                controller: _title,
                                label: 'Story Title',
                                required: true),
                            SizedBox(height: 10.h),
                            _InputField(
                                controller: _readMin,
                                label: 'Read Time (minutes)',
                                required: true,
                                inputType: TextInputType.number),
                          ]),

                          SizedBox(height: 10.h),

                          // Story type dropdown
                          _label('Story Type *'),
                          SizedBox(height: 4.h),
                          DropdownButtonFormField<String>(
                            value: _selectedType,
                            isExpanded: true,
                            decoration: _inputDecoration('Select story type'),
                            items: _storyTypes
                                .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 13.sp)),
                            ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedType = v),
                            validator: (v) =>
                            v == null ? 'Please select a type' : null,
                          ),

                          SizedBox(height: 18.h),

                          // Story content section
                          _SectionLabel('Story Content'),
                          SizedBox(height: 10.h),
                          _TextArea(
                            controller: _full,
                            label: 'Full Story Content',
                            maxLines: 7,
                            maxLength: 5000,
                            required: true,
                          ),

                          SizedBox(height: 18.h),

                          // Cultural context section
                          _SectionLabel('Cultural Context'),
                          SizedBox(height: 10.h),
                          _TextArea(
                            controller: _hist,
                            label: 'Historical Context (optional)',
                            maxLines: 4,
                            maxLength: 500,
                          ),
                          SizedBox(height: 10.h),
                          _TextArea(
                            controller: _cult,
                            label: 'Cultural Significance (optional)',
                            maxLines: 4,
                            maxLength: 500,
                          ),

                          SizedBox(height: 18.h),

                          // Image upload section
                          _SectionLabel('Story Images'),
                          SizedBox(height: 10.h),
                          _ImageUploadArea(
                            files: _files,
                            onPick: loading ? null : _pickFiles,
                            onRemove: _removeFile,
                          ),

                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Actions ─────────────────────────────────────────
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    border:
                    Border(top: BorderSide(color: _border, width: 1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancel',
                            style: GoogleFonts.dmSans(
                                fontSize: 13.sp, color: Colors.grey[600])),
                      ),
                      SizedBox(width: 10.w),
                      SizedBox(
                        height: 42.h,
                        child: ElevatedButton(
                          onPressed: loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24.w, vertical: 10.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r)),
                            elevation: 0,
                          ),
                          child: loading
                              ? SizedBox(
                            width: 18.w,
                            height: 18.h,
                            child: const CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                              : Text('Add Story',
                              style: GoogleFonts.dmSans(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.dmSans(fontSize: 13.sp, color: Colors.grey[400]),
    contentPadding:
    EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: _border)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: _border)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: _accent, width: 1.5)),
    filled: true,
    fillColor: _bg,
  );

  Widget _label(String text) => Text(text,
      style: GoogleFonts.dmSans(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700]));
}

// ── Reusable sub-widgets ─────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 12.w, 16.h),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: const Color(0xFF3D5A80),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text('Add New Cultural Story',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 18.sp, fontWeight: FontWeight.bold)),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, size: 20.sp, color: Colors.grey[600]),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E))),
        SizedBox(width: 8.w),
        Expanded(child: Divider(color: Colors.grey.shade200)),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool required;
  final TextInputType inputType;

  const _InputField({
    required this.controller,
    required this.label,
    this.required = false,
    this.inputType = TextInputType.text,
  });

  static const _border  = Color(0xFFDDDDDD);
  static const _accent  = Color(0xFF3D5A80);
  static const _bg      = Color(0xFFF8F8F8);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label${required ? ' *' : ''}',
            style: GoogleFonts.dmSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700])),
        SizedBox(height: 4.h),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          style: GoogleFonts.dmSans(fontSize: 13.sp),
          decoration: InputDecoration(
            contentPadding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: _border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: _border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: _accent, width: 1.5)),
            filled: true,
            fillColor: _bg,
          ),
          validator: required
              ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
              : null,
        ),
      ],
    );
  }
}

class _TextArea extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final int maxLength;
  final bool required;

  const _TextArea({
    required this.controller,
    required this.label,
    this.maxLines = 4,
    this.maxLength = 500,
    this.required = false,
  });

  static const _border = Color(0xFFDDDDDD);
  static const _accent = Color(0xFF3D5A80);
  static const _bg     = Color(0xFFF8F8F8);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label${required ? ' *' : ''}',
            style: GoogleFonts.dmSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700])),
        SizedBox(height: 4.h),
        TextFormField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          style: GoogleFonts.dmSans(fontSize: 13.sp),
          decoration: InputDecoration(
            contentPadding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: _border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: _border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: _accent, width: 1.5)),
            filled: true,
            fillColor: _bg,
          ),
          validator: required
              ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
              : null,
        ),
      ],
    );
  }
}

class _ImageUploadArea extends StatelessWidget {
  final List<PlatformFile> files;
  final VoidCallback? onPick;
  final void Function(int index) onRemove;

  const _ImageUploadArea({
    required this.files,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upload button
        GestureDetector(
          onTap: onPick,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                  color: Colors.grey.shade300, style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Icon(Icons.cloud_upload_outlined,
                    size: 28.sp, color: Colors.grey[500]),
                SizedBox(height: 6.h),
                Text('Click to upload images (max 3)',
                    style: GoogleFonts.dmSans(
                        fontSize: 12.sp, color: Colors.grey[500])),
                Text('PNG, JPG, JPEG, WEBP',
                    style: GoogleFonts.dmSans(
                        fontSize: 11.sp, color: Colors.grey[400])),
              ],
            ),
          ),
        ),

        // Selected files chips
        if (files.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: files.asMap().entries.map((e) {
              return Chip(
                label: Text(e.value.name,
                    style:
                    GoogleFonts.dmSans(fontSize: 11.sp)),
                deleteIcon: Icon(Icons.close, size: 14.sp),
                onDeleted: () => onRemove(e.key),
                backgroundColor: Colors.grey.shade100,
                side: BorderSide(color: Colors.grey.shade300),
                padding: EdgeInsets.symmetric(
                    horizontal: 8.w, vertical: 2.h),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}