import 'package:flutter/material.dart';
import 'package:lokyatra_frontend/core/constants.dart';

/// Converts Cloudinary URL to thumbnail
String cloudinaryThumb(String url, {int w = 300, int h = 300}) {
  final idx = url.indexOf('/upload/');
  if (idx == -1) return url;
  final before = url.substring(0, idx + '/upload/'.length);
  final after = url.substring(idx + '/upload/'.length);
  return '${before}c_fill,w_$w,h_$h,q_auto,f_auto/$after';
}

/// Routes image through backend proxy
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

class ProxyImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadiusValue;
  final bool thumb;

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

    // ✅ SAFETY FIX FOR INFINITY / NaN
    final safeWidth =
    (width.isInfinite || width.isNaN) ? MediaQuery.of(context).size.width : width;

    final safeHeight =
    (height.isInfinite || height.isNaN) ? 200.0 : height;

    // ✅ Only convert to int AFTER safety check
    final urlToLoad = thumb
        ? cloudinaryThumb(
      imageUrl!,
      w: safeWidth.toInt(),
      h: safeHeight.toInt(),
    )
        : imageUrl!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadiusValue),
      child: Image.network(
        getProxyImageUrl(urlToLoad),
        width: safeWidth,
        height: safeHeight,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _placeholder(width: safeWidth, height: safeHeight, loading: true);
        },
        errorBuilder: (_, __, ___) =>
            _placeholder(width: safeWidth, height: safeHeight, broken: true),
      ),
    );
  }

  Widget _placeholder({
    double? width,
    double? height,
    bool loading = false,
    bool broken = false,
  }) {
    return Container(
      width: width ?? this.width,
      height: height ?? this.height,
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