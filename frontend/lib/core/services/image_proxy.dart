import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lokyatra_frontend/core/services/constants.dart';

String cloudinaryThumb(String url, {int w = 300, int h = 300}) {
  final idx = url.indexOf('/upload/');
  if (idx == -1) return url;
  final before = url.substring(0, idx + '/upload/'.length);
  final after = url.substring(idx + '/upload/'.length);
  return '${before}c_fill,w_$w,h_$h,q_auto,f_auto/$after';
}

String cloudinaryFull(String url) {
  final idx = url.indexOf('/upload/');
  if (idx == -1) return url;
  final before = url.substring(0, idx + '/upload/'.length);
  final after = url.substring(idx + '/upload/'.length);
  return '${before}q_auto,f_auto/$after';
}

String getProxyImageUrl(String originalUrl) {
  // Decode first to prevent double-encoding of any % characters already in the URL
  final decoded = Uri.decodeFull(originalUrl);
  return '${apiBaseUrl}api/Sites/proxy-image?url=${Uri.encodeComponent(decoded)}';
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
  final String? overrideCacheKey;

  const ProxyImage({
    super.key,
    required this.imageUrl,
    this.width = 60,
    this.height = 60,
    this.borderRadiusValue = 8,
    this.thumb = false,
    this.overrideCacheKey,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) return _blank();

    final safeW = (width.isInfinite || width.isNaN)
        ? MediaQuery.of(context).size.width
        : width;
    final safeH = (height.isInfinite || height.isNaN) ? 200.0 : height;

    final bool isCloudinary = imageUrl!.contains('/upload/');

    final String resolvedUrl = isCloudinary
        ? (thumb
        ? cloudinaryThumb(imageUrl!, w: safeW.toInt(), h: safeH.toInt())
        : cloudinaryFull(imageUrl!))
        : imageUrl!;

    final String finalImageUrl = getProxyImageUrl(resolvedUrl);

    final cacheKey = overrideCacheKey ??
        (thumb ? 'thumb_${imageUrl!}' : 'full_${imageUrl!}');

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadiusValue),
      child: CachedNetworkImage(
        imageUrl: finalImageUrl,
        cacheKey: cacheKey,
        width: safeW,
        height: safeH,
        fit: BoxFit.cover,
        placeholder: (_, __) => _loading(safeW, safeH),
        errorWidget: (_, __, ___) => _broken(safeW, safeH),
      ),
    );
  }

  Widget _blank() => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(borderRadiusValue),
    ),
    child: Center(
      child: Icon(Icons.image_outlined, color: Colors.grey[300], size: 28),
    ),
  );

  Widget _loading(double w, double h) => Container(
    width: w,
    height: h,
    color: Colors.grey[100],
    child: Center(
      child: CircularProgressIndicator(
        strokeWidth: 1.5,
        color: Colors.grey[300],
      ),
    ),
  );

  Widget _broken(double w, double h) => Container(
    width: w,
    height: h,
    color: Colors.grey[100],
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_outlined, size: 32, color: Colors.grey[300]),
        const SizedBox(height: 4),
        Text(
          'No image',
          style: TextStyle(fontSize: 10, color: Colors.grey[400]),
        ),
      ],
    ),
  );
}