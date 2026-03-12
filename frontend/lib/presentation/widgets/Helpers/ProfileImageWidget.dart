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
  State<ProfileImageWidget> createState() => ProfileImageWidgetState();
}

class ProfileImageWidgetState extends State<ProfileImageWidget> {
  String? url;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    url = widget.initialImageUrl;
  }

  @override
  void didUpdateWidget(ProfileImageWidget old) {
    super.didUpdateWidget(old);
    if (old.initialImageUrl != widget.initialImageUrl) {
      setState(() => url = widget.initialImageUrl);
    }
  }

  Future<void> pick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;

    setState(() => busy = true);
    try {
      final res = await UserRemoteDatasource().updateProfile(
        imageFile: file,
      );
      if (res.statusCode == 200) {
        final newUrl = res.data['profileImage'] as String?;
        if (newUrl != null && newUrl.isNotEmpty) {
          await SqliteService().put('user_profile_image', newUrl);
          if (mounted) setState(() => url = newUrl);
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
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;
    final r     = isWeb ? widget.radius : widget.radius.r;

    return GestureDetector(
      onTap: busy ? null : pick,
      child: Stack(clipBehavior: Clip.none, children: [
        CircleAvatar(
          radius: r,
          backgroundColor: widget.accent.withValues(alpha: 0.1),
          child: busy
              ? SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: widget.accent),
          )
              : (url != null && url!.isNotEmpty
              ? ClipOval(
            child: ProxyImage(
              imageUrl: url,
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