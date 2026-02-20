import 'package:flutter/material.dart';
import 'package:lokyatra_frontend/core/constants.dart';

/// Converts a Cloudinary URL to a thumbnail using Cloudinary transformations.
/// Instead of loading a full 4MB image, this serves a small cropped version.
/// Use this for list views / thumbnails. For full-size images, use original URL.
String cloudinaryThumb(String url, {int w = 300, int h = 300}) {
  final idx = url.indexOf('/upload/');
  if (idx == -1) return url; // not a cloudinary URL, return as-is
  final before = url.substring(0, idx + '/upload/'.length);
  final after  = url.substring(idx + '/upload/'.length);
  return '${before}c_fill,w_$w,h_$h,q_auto,f_auto/$after';
}

/// Routes image through your backend proxy.
/// The emulator/phone can't reach Cloudinary directly,
/// but it can reach your backend which fetches and forwards the image.
String getProxyImageUrl(String originalUrl) {
  return '${apiBaseUrl}api/Sites/proxy-image?url=${Uri.encodeComponent(originalUrl)}';
}

String? getFirstImageUrl(dynamic imageUrls) {
  if (imageUrls is List && imageUrls.isNotEmpty) {
    final first = imageUrls.first?.toString();
    if (first != null && first.isNotEmpty) return first;
  }
  return null;
}

/// Image widget that loads through your backend proxy.
/// Pass [thumb: true] for list views to load a smaller Cloudinary thumbnail.
class ProxyImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadiusValue;
  final bool thumb; // if true, uses cloudinaryThumb for smaller payload

  const ProxyImage({
    super.key,
    required this.imageUrl,
    this.width = 60,
    this.height = 60,
    this.borderRadiusValue = 8,
    this.thumb = false,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _placeholder();
    }

    // If thumb mode, transform URL before proxying
    final urlToLoad = thumb
        ? cloudinaryThumb(imageUrl!, w: width.toInt(), h: height.toInt())
        : imageUrl!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadiusValue),
      child: Image.network(
        getProxyImageUrl(urlToLoad),
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _placeholder(loading: true);
        },
        errorBuilder: (_, __, ___) => _placeholder(broken: true),
      ),
    );
  }

  Widget _placeholder({bool loading = false, bool broken = false}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadiusValue),
      ),
      child: Center(
        child: loading
            ? const CircularProgressIndicator(strokeWidth: 2)
            : Icon(
          broken ? Icons.broken_image : Icons.image,
          color: Colors.grey,
        ),
      ),
    );
  }
}