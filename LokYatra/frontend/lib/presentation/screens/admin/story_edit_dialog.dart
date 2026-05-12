import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/data/datasources/stories_remote_datasource.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';

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

class StoryEditDialog extends StatefulWidget {
  final Map<String, dynamic> story;
  const StoryEditDialog({super.key, required this.story});

  @override
  State<StoryEditDialog> createState() => _StoryEditDialogState();
}

class _StoryEditDialogState extends State<StoryEditDialog> {
  static const _accent  = Color(0xFF3D5A80);
  static const _border  = Color(0xFFDDDDDD);
  static const _bg      = Color(0xFFF8F8F8);

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final _titleController = TextEditingController(text: (widget.story['title'] ?? '').toString());
  late final _readTimeController = TextEditingController(text: (widget.story['estimatedReadTimeMinutes'] ?? 5).toString());
  late final _contentController = TextEditingController(text: (widget.story['fullContent'] ?? '').toString());
  late final _historicalController = TextEditingController(text: (widget.story['historicalContext'] ?? '').toString());
  late final _culturalController = TextEditingController(text: (widget.story['culturalSignificance'] ?? '').toString());
  
  String? _selectedType;
  final List<PlatformFile> _newFiles = [];
  late final List<String> _existingImageUrls = _getExistingImageUrls();

  @override
  void initState() {
    super.initState();
    _selectedType = (widget.story['storyType'] ?? '').toString();
    if (!_storyTypes.contains(_selectedType)) {
      _selectedType = 'Other';
    }
  }

  List<String> _getExistingImageUrls() {
    List<String> urls = [];
    if (widget.story['imageUrls'] != null && widget.story['imageUrls'] is List) {
      for (var url in widget.story['imageUrls']) {
        if (url != null && url.toString().isNotEmpty) {
          urls.add(url.toString());
        }
      }
    }
    return urls;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _readTimeController.dispose();
    _contentController.dispose();
    _historicalController.dispose();
    _culturalController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
    );
    if (result != null) {
      setState(() {
        _newFiles.addAll(result.files.take(3));
      });
    }
  }

  void _removeNewFile(int index) => setState(() => _newFiles.removeAt(index));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Map<String, dynamic> fields = {
      'CulturalSiteId': widget.story['culturalSiteId'] ?? 0,
      'Title': _titleController.text.trim(),
      'StoryType': _selectedType ?? 'Other',
      'EstimatedReadTimeMinutes': int.tryParse(_readTimeController.text.trim()) ?? 5,
      'FullContent': _contentController.text.trim(),
      'HistoricalContext': _historicalController.text.trim().isEmpty ? null : _historicalController.text.trim(),
      'CulturalSignificance': _culturalController.text.trim().isEmpty ? null : _culturalController.text.trim(),
      'ExistingImagesJson': json.encode(_existingImageUrls),
    };

    try {
      final response = await StoriesRemoteDatasource().updateStory(
        id: widget.story['id'] as int,
        fields: fields,
        files: _newFiles,
      );

      if (mounted) {
        setState(() => _isLoading = false);
      }

      if (response.statusCode == 200) {
        if (mounted) Navigator.pop(context, true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Update failed: ${response.statusCode}', style: GoogleFonts.dmSans()),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: $error', style: GoogleFonts.dmSans()),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                              controller: _titleController,
                              label: 'Story Title',
                              required: true,
                              isWide: isWide,
                            )),
                        SizedBox(width: isWide ? 16 : 12.w),
                        Expanded(
                            child: _InputField(
                              controller: _readTimeController,
                              label: 'Read Time (min)',
                              required: true,
                              inputType: TextInputType.number,
                              isWide: isWide,
                            )),
                      ])
                          : Column(children: [
                        _InputField(
                            controller: _titleController,
                            label: 'Story Title',
                            required: true,
                            isWide: isWide),
                        SizedBox(height: 12.h),
                        _InputField(
                            controller: _readTimeController,
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
                        controller: _contentController,
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
                        controller: _historicalController,
                        label: 'Historical Context (optional)',
                        maxLines: 4,
                        maxLength: 500,
                        isWide: isWide,
                      ),
                      SizedBox(height: isWide ? 16 : 10.h),
                      _TextArea(
                        controller: _culturalController,
                        label: 'Cultural Significance (optional)',
                        maxLines: 4,
                        maxLength: 500,
                        isWide: isWide,
                      ),

                      SizedBox(height: isWide ? 24 : 18.h),

                      if (_existingImageUrls.isNotEmpty) ...[
                        _SectionLabel('Existing Images', isWide: isWide),
                        SizedBox(height: isWide ? 16 : 10.h),
                        SizedBox(
                          height: isWide ? 100 : 80.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _existingImageUrls.length,
                            separatorBuilder: (context, index) => SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final url = _existingImageUrls[index];
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: ProxyImage(
                                      imageUrl: url,
                                      width: isWide ? 100 : 80.w,
                                      height: isWide ? 100 : 80.h,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => setState(() => _existingImageUrls.remove(url)),
                                      child: Container(
                                        padding: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.close, size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(height: isWide ? 24 : 18.h),
                      ],

                      _SectionLabel('Upload New Images', isWide: isWide),
                      SizedBox(height: isWide ? 16 : 10.h),
                      _ImageUploadArea(
                        files: _newFiles,
                        onPick: _isLoading ? null : _pickFiles,
                        onRemove: _removeNewFile,
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
                      onPressed: _isLoading ? null : _submit,
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
                      child: _isLoading
                          ? SizedBox(
                        width: isWide ? 18 : 18.w,
                        height: isWide ? 18 : 18.h,
                        child: const CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                          : Text('Save Changes',
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
            child: Text('Edit Cultural Story',
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
