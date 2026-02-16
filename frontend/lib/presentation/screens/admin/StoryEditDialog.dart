import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lokyatra_frontend/data/datasources/Stories_remote_datasource.dart';

class StoryEditDialog extends StatefulWidget {
  final Map<String, dynamic> story;
  const StoryEditDialog({super.key, required this.story});

  @override
  State<StoryEditDialog> createState() => _StoryEditDialogState();
}

class _StoryEditDialogState extends State<StoryEditDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Text controllers - initialized with existing story data
  late final _titleController = TextEditingController(text: (widget.story['title'] ?? '').toString());
  late final _typeController = TextEditingController(text: (widget.story['storyType'] ?? '').toString());
  late final _readTimeController = TextEditingController(text: (widget.story['estimatedReadTimeMinutes'] ?? 5).toString());
  late final _contentController = TextEditingController(text: (widget.story['fullContent'] ?? '').toString());
  late final _historicalController = TextEditingController(text: (widget.story['historicalContext'] ?? '').toString());
  late final _culturalController = TextEditingController(text: (widget.story['culturalSignificance'] ?? '').toString());

  // Images
  List<PlatformFile> _newFiles = [];
  late List<String> _existingImageUrls = _getExistingImageUrls();

  /// Gets the existing image URLs from story data using a simple loop
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
    _typeController.dispose();
    _readTimeController.dispose();
    _contentController.dispose();
    _historicalController.dispose();
    _culturalController.dispose();
    super.dispose();
  }

  // ─── Pick files ───

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
    );
    if (result != null) {
      setState(() {
        _newFiles.addAll(result.files.take(5));
      });
    }
  }

  // ─── Submit ───

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Get original image count
    int originalImageCount = 0;
    if (widget.story['imageUrls'] != null && widget.story['imageUrls'] is List) {
      originalImageCount = (widget.story['imageUrls'] as List).length;
    }

    // If user removed images but didn't add new ones, warn them
    if (_newFiles.isEmpty && _existingImageUrls.length != originalImageCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('To apply image removals, please upload at least one new image.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    Map<String, dynamic> fields = {
      'CulturalSiteId': widget.story['culturalSiteId'] ?? 0,
      'Title': _titleController.text.trim(),
      'StoryType': _typeController.text.trim(),
      'EstimatedReadTimeMinutes': int.tryParse(_readTimeController.text.trim()) ?? 5,
      'FullContent': _contentController.text.trim(),
      'HistoricalContext': _historicalController.text.trim().isEmpty ? null : _historicalController.text.trim(),
      'CulturalSignificance': _culturalController.text.trim().isEmpty ? null : _culturalController.text.trim(),
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
            SnackBar(content: Text('Update failed: ${response.statusCode}')),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $error')),
        );
      }
    }
  }

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double dialogWidth = screenWidth > 900 ? 900.0 : screenWidth * 0.95;

    return AlertDialog(
      title: Row(
        children: [
          const Expanded(child: Text('Edit Story', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          IconButton(onPressed: () => Navigator.pop(context, false), icon: const Icon(Icons.close)),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Type
                Row(children: [
                  _buildTextField(_titleController, 'Title *', required: true),
                  const SizedBox(width: 12),
                  _buildTextField(_typeController, 'Type *', required: true),
                ]),
                const SizedBox(height: 8),

                // Read time
                TextFormField(
                  controller: _readTimeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Read Time (minutes) *', border: OutlineInputBorder()),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // Full content
                const Text('Story Content', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _buildTextArea(_contentController, 'Full Story Content *', maxLength: 5000, required: true),
                const SizedBox(height: 12),

                // Cultural context
                const Text('Cultural Context', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _buildTextArea(_historicalController, 'Historical Context', maxLength: 500),
                const SizedBox(height: 8),
                _buildTextArea(_culturalController, 'Moral Lesson / Cultural Significance', maxLength: 500),
                const SizedBox(height: 12),

                // Existing images
                const Text('Existing Images (remove if needed)'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _existingImageUrls.map((url) {
                    return Chip(
                      label: SizedBox(width: 160, child: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      onDeleted: () => setState(() => _existingImageUrls.remove(url)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // New images
                const Text('Upload New Images (replaces existing)'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickFiles,
                      icon: const Icon(Icons.upload),
                      label: const Text('Choose Files'),
                    ),
                    ..._newFiles.map((file) => Chip(label: Text(file.name))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Save Changes'),
        ),
      ],
    );
  }

  // ─── Helper widgets ───

  /// Text field inside a Row (uses Expanded)
  Widget _buildTextField(TextEditingController controller, String label, {bool required = false}) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: required
            ? (value) => (value == null || value.trim().isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }

  /// Multi-line text area (full width)
  Widget _buildTextArea(TextEditingController controller, String label, {int maxLength = 500, bool required = false}) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      maxLines: 6,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: required
          ? (value) => (value == null || value.trim().isEmpty) ? 'Required' : null
          : null,
    );
  }
}