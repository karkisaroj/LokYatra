import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import 'package:lokyatra_frontend/data/datasources/user_remote_datasource.dart';
import '../../../core/services/sqlite_service.dart';

class ProfileImageWidget extends StatefulWidget {
  final String? initialImageUrl;
  final Color accent;
  final double radius;
  final void Function(String)? onUploaded;

  const ProfileImageWidget({
    super.key,
    this.initialImageUrl,
    this.accent = const Color(0xFFCD6E4E),
    this.radius = 50,
    this.onUploaded,
  });

  @override
  State<ProfileImageWidget> createState() => _ProfileImageWidgetState();
}

class _ProfileImageWidgetState extends State<ProfileImageWidget> {
  String? _url;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _url = widget.initialImageUrl;
  }

  @override
  void didUpdateWidget(ProfileImageWidget old) {
    super.didUpdateWidget(old);
    if (old.initialImageUrl != widget.initialImageUrl) {
      _url = widget.initialImageUrl;
    }
  }

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.path == null) return;

    setState(() => _busy = true);
    try {
      final res = await UserRemoteDatasource().updateProfile(
        imagePath: file.path,
        imageFileName: file.name,
      );
      if (res.statusCode == 200) {
        final newUrl = res.data['profileImage'] as String?;
        if (newUrl != null && newUrl.isNotEmpty) {
          await SqliteService().put('user_profile_image', newUrl);
          if (mounted) setState(() => _url = newUrl);
          widget.onUploaded?.call(newUrl);
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;
    final r = isWeb ? widget.radius : widget.radius.r;

    return GestureDetector(
      onTap: _busy ? null : _pick,
      child: Stack(clipBehavior: Clip.none, children: [
        CircleAvatar(
          radius: r,
          backgroundColor: widget.accent.withValues(alpha: 0.1),
          child: _busy
              ? SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: widget.accent),
          )
              : (_url != null && _url!.isNotEmpty
              ? ClipOval(
            child: ProxyImage(
              imageUrl: _url,
              width: r * 2,
              height: r * 2,
              borderRadiusValue: r,
            ),
          )
              : Icon(Icons.person_rounded,
              size: r * 1.1, color: widget.accent)),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: widget.accent,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(Icons.camera_alt_rounded,
                size: isWeb ? 14 : 12.sp, color: Colors.white),
          ),
        ),
      ]),
    );
  }
}