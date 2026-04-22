import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/stories/story_bloc.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/stories/story_event.dart';
import 'package:lokyatra_frontend/presentation/state_management/Bloc/stories/story_state.dart';

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
        final size    = MediaQuery.of(context).size;
        final isWide  = size.width > 600;

        return Dialog(
          backgroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isWide ? 12 : 16.r)),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isWide ? 40 : 16.w,
            vertical: isWide ? 40 : 32.h,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? 700 : 340,
              maxHeight: size.height * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Header(
                  isWide: isWide,
                  onClose: () => Navigator.pop(context, false),
                ),

                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isWide ? 32 : 24.w,
                      isWide ? 16 : 0,
                      isWide ? 32 : 24.w,
                      isWide ? 24 : 8.h,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel('Basic Information', isWide: isWide),
                          SizedBox(height: isWide ? 16 : 10.h),

                          isWide
                              ? Row(children: [
                            Expanded(
                                flex: 3,
                                  child: _InputField(
                                    controller: _title,
                                    label: 'Story Title',
                                    required: true,
                                    isWide: isWide,
                                  )),
                              SizedBox(width: isWide ? 16 : 12.w),
                              Expanded(
                                  child: _InputField(
                                    controller: _readMin,
                                    label: 'Read Time (min)',
                                    required: true,
                                    inputType: TextInputType.number,
                                    isWide: isWide,
                                  )),
                            ])
                                : Column(children: [
                              _InputField(
                                  controller: _title,
                                  label: 'Story Title',
                                  required: true,
                                  isWide: isWide),
                              SizedBox(height: 12.h),
                              _InputField(
                                  controller: _readMin,
                                  label: 'Read Time (minutes)',
                                  required: true,
                                  inputType: TextInputType.number,
                                  isWide: isWide),
                            ]),

                            SizedBox(height: isWide ? 20 : 10.h),

                            _label('Story Type *', isWide),
                            SizedBox(height: isWide ? 6 : 4.h),
                            DropdownButtonFormField<String>(
                              value: _selectedType,
                              isExpanded: true,
                              decoration: _inputDecoration('Select story type', isWide),
                              items: _storyTypes
                                  .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(t,
                                    style: GoogleFonts.dmSans(
                                        fontSize: isWide ? 14 : 13.sp)),
                              ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedType = v),
                              validator: (v) =>
                              v == null ? 'Please select a type' : null,
                            ),

                            SizedBox(height: isWide ? 24 : 18.h),

                            _SectionLabel('Story Content', isWide: isWide),
                            SizedBox(height: isWide ? 16 : 10.h),
                            _TextArea(
                              controller: _full,
                              label: 'Full Story Content',
                              maxLines: isWide ? 10 : 7,
                              maxLength: 5000,
                              required: true,
                              isWide: isWide,
                            ),

                            SizedBox(height: isWide ? 24 : 18.h),

                            _SectionLabel('Cultural Context', isWide: isWide),
                            SizedBox(height: isWide ? 16 : 10.h),
                            _TextArea(
                              controller: _hist,
                              label: 'Historical Context (optional)',
                              maxLines: 4,
                              maxLength: 500,
                              isWide: isWide,
                            ),
                            SizedBox(height: isWide ? 16 : 10.h),
                            _TextArea(
                              controller: _cult,
                              label: 'Cultural Significance (optional)',
                              maxLines: 4,
                              maxLength: 500,
                              isWide: isWide,
                            ),

                            SizedBox(height: isWide ? 24 : 18.h),

                            _SectionLabel('Story Images', isWide: isWide),
                            SizedBox(height: isWide ? 16 : 10.h),
                            _ImageUploadArea(
                              files: _files,
                              onPick: loading ? null : _pickFiles,
                              onRemove: _removeFile,
                              isWide: isWide,
                            ),

                          SizedBox(height: isWide ? 8 : 8.h),
                        ],
                      ),
                    ),
                  ),
                ),

                Container(
                  padding:
                  EdgeInsets.symmetric(
                      horizontal: isWide ? 24 : 24.w,
                      vertical: isWide ? 16 : 16.h),
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
                                fontSize: isWide ? 13 : 13.sp, color: Colors.grey[600])),
                      ),
                      SizedBox(width: isWide ? 10 : 10.w),
                      SizedBox(
                        height: isWide ? 42 : 42.h,
                        child: ElevatedButton(
                          onPressed: loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: isWide ? 24 : 24.w,
                                vertical: isWide ? 10 : 10.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(isWide ? 10 : 10.r)),
                            elevation: 0,
                          ),
                          child: loading
                              ? SizedBox(
                            width: isWide ? 18 : 18.w,
                            height: isWide ? 18 : 18.h,
                            child: const CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                              : Text('Add Story',
                              style: GoogleFonts.dmSans(
                                  fontSize: isWide ? 13 : 13.sp,
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

  InputDecoration _inputDecoration(String hint, bool isWide) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.dmSans(
        fontSize: isWide ? 14 : 13.sp, color: Colors.grey[400]),
    contentPadding:
    EdgeInsets.symmetric(
        horizontal: isWide ? 12 : 12.w, vertical: isWide ? 12 : 12.h),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isWide ? 8 : 8.r),
        borderSide: const BorderSide(color: _border)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isWide ? 8 : 8.r),
        borderSide: const BorderSide(color: _border)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isWide ? 8 : 8.r),
        borderSide: const BorderSide(color: _accent, width: 1.5)),
    filled: true,
    fillColor: _bg,
  );

  Widget _label(String text, bool isWide) {
    return Text(text,
        style: GoogleFonts.dmSans(
            fontSize: isWide ? 14 : 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700]));
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  final bool isWide;
  const _Header({required this.onClose, required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          isWide ? 32 : 24.w, isWide ? 24 : 20.h, isWide ? 16 : 12.w, isWide ? 20 : 16.h),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            width: isWide ? 4 : 4.w,
            height: isWide ? 24 : 20.h,
            decoration: BoxDecoration(
              color: const Color(0xFF3D5A80),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: isWide ? 12 : 10.w),
          Expanded(
            child: Text('Add New Cultural Story',
                style: GoogleFonts.playfairDisplay(
                    fontSize: isWide ? 22 : 18.sp, fontWeight: FontWeight.bold)),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, size: isWide ? 22 : 20.sp, color: Colors.grey[600]),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isWide;
  const _SectionLabel(this.label, {required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: isWide ? 15 : 13.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E))),
        SizedBox(width: 12),
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
  final bool isWide;

  const _InputField({
    required this.controller,
    required this.label,
    required this.isWide,
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
                fontSize: isWide ? 13 : 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700])),
        SizedBox(height: isWide ? 6 : 4.h),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          style: GoogleFonts.dmSans(fontSize: isWide ? 14 : 13.sp),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
                horizontal: isWide ? 14 : 12.w, vertical: isWide ? 14 : 12.h),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isWide ? 8 : 8.r),
                borderSide: const BorderSide(color: _border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isWide ? 8 : 8.r),
                borderSide: const BorderSide(color: _border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isWide ? 8 : 8.r),
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
  final bool isWide;

  const _TextArea({
    required this.controller,
    required this.label,
    required this.isWide,
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
                fontSize: isWide ? 13 : 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700])),
        SizedBox(height: isWide ? 6 : 4.h),
        TextFormField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          style: GoogleFonts.dmSans(fontSize: isWide ? 14 : 13.sp),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
                horizontal: isWide ? 14 : 12.w, vertical: isWide ? 14 : 12.h),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isWide ? 8 : 8.r),
                borderSide: const BorderSide(color: _border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isWide ? 8 : 8.r),
                borderSide: const BorderSide(color: _border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isWide ? 8 : 8.r),
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
  final bool isWide;

  const _ImageUploadArea({
    required this.files,
    required this.onPick,
    required this.onRemove,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onPick,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isWide ? 20 : 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(isWide ? 8 : 8.r),
              border: Border.all(
                  color: Colors.grey.shade300, style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Icon(Icons.cloud_upload_outlined,
                    size: isWide ? 32 : 28.sp, color: Colors.grey[500]),
                SizedBox(height: isWide ? 8 : 6.h),
                Text('Click to upload images (max 3)',
                    style: GoogleFonts.dmSans(
                        fontSize: isWide ? 14 : 12.sp, color: Colors.grey[500])),
                Text('PNG, JPG, JPEG, WEBP',
                    style: GoogleFonts.dmSans(
                        fontSize: isWide ? 12 : 11.sp, color: Colors.grey[400])),
              ],
            ),
          ),
        ),

        if (files.isNotEmpty) ...[
          SizedBox(height: isWide ? 12 : 8.h),
          Wrap(
            spacing: isWide ? 10 : 8.w,
            runSpacing: isWide ? 8 : 6.h,
            children: files.asMap().entries.map((e) {
              return Chip(
                label: Text(e.value.name,
                    style:
                    GoogleFonts.dmSans(fontSize: isWide ? 13 : 11.sp)),
                deleteIcon: Icon(Icons.close, size: isWide ? 16 : 14.sp),
                onDeleted: () => onRemove(e.key),
                backgroundColor: Colors.grey.shade100,
                side: BorderSide(color: Colors.grey.shade300),
                padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 10 : 8.w, vertical: isWide ? 4 : 2.h),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}