import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import 'package:lokyatra_frontend/data/datasources/user_remote_datasource.dart';
import 'package:lokyatra_frontend/presentation/widgets/Helpers/SecureStorageService.dart';

class ProfileImageWidget extends StatefulWidget {
  final String? initialImageUrl;
  final Color accentColor;
  final double radius;
  final void Function(String newUrl)? onUploaded;

  const ProfileImageWidget({
    super.key,
    this.initialImageUrl,
    this.accentColor = const Color(0xFF5C4033),
    this.radius = 50,
    this.onUploaded,
  });

  @override
  State<ProfileImageWidget> createState() => _ProfileImageWidgetState();
}

class _ProfileImageWidgetState extends State<ProfileImageWidget> {
  late String? _imageUrl;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
  }

  // Sync if parent passes a new URL (e.g. after page reload)
  @override
  void didUpdateWidget(ProfileImageWidget old) {
    super.didUpdateWidget(old);
    if (old.initialImageUrl != widget.initialImageUrl) {
      _imageUrl = widget.initialImageUrl;
    }
  }

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) return;

    setState(() => _uploading = true);

    try {
      final res = await UserRemoteDatasource().updateProfile(
        imagePath: file.path,
        imageFileName: file.name,
      );

      if (res.statusCode == 200) {
        final newUrl = res.data['profileImage'] as String?;
        if (newUrl != null && newUrl.isNotEmpty) {
          await SecureStorageService.updateProfileImage(newUrl);
          if (mounted) setState(() => _imageUrl = newUrl);
          widget.onUploaded?.call(newUrl);
        }
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.radius.r;

    return GestureDetector(
      onTap: _uploading ? null : _pick,
      child: Stack(
        children: [
          // Avatar circle
          CircleAvatar(
            radius: r,
            backgroundColor: widget.accentColor.withValues(alpha: 0.1),
            child: _uploading
                ? SizedBox(
              width: 28.w,
              height: 28.h,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: widget.accentColor),
            )
                : (_imageUrl != null && _imageUrl!.isNotEmpty
                ? ClipOval(
              child: ProxyImage(
                imageUrl: _imageUrl,
                width: r * 2,
                height: r * 2,
                borderRadiusValue: r,
              ),
            )
                : Icon(Icons.person_rounded,
                size: (r * 1.1).sp, color: widget.accentColor)),
          ),

          // Camera badge
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: widget.accentColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(Icons.camera_alt_rounded,
                  size: 12.sp, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}