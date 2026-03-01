import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lokyatra_frontend/core/constants.dart';

String cloudinaryThumb(String url, {int w = 300, int h = 300}) {
  final idx = url.indexOf('/upload/');
  if (idx == -1) return url;
  final before = url.substring(0, idx + '/upload/'.length);
  final after  = url.substring(idx + '/upload/'.length);
  return '${before}c_fill,w_$w,h_$h,q_auto,f_auto/$after';
}

String getProxyImageUrl(String originalUrl) =>
    '${apiBaseUrl}api/Sites/proxy-image?url=${Uri.encodeComponent(originalUrl)}';

String? getFirstImageUrl(dynamic imageUrls) {
  if (imageUrls is List && imageUrls.isNotEmpty) {
    final first = imageUrls.first?.toString();
    if (first != null && first.isNotEmpty) return first;
  }
  return null;
}

/// ProxyImage — routes through backend proxy, caches to disk.
///
/// IMPORTANT: cacheKey is ALWAYS the raw original imageUrl (not the proxy
/// wrapper, not the thumb transform).  This means a thumbnail loaded on the
/// list screen and a full-size image on the detail screen share the same cache
/// entry — so offline the detail page can reuse what was already cached.
class ProxyImage extends StatelessWidget {
  final String? imageUrl;
  final double  width;
  final double  height;
  final double  borderRadiusValue;
  final bool    thumb;

  const ProxyImage({
    super.key,
    required this.imageUrl,
    this.width             = 60,
    this.height            = 60,
    this.borderRadiusValue = 8,
    this.thumb             = false,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) return _blank();

    final safeW = (width.isInfinite  || width.isNaN)
        ? MediaQuery.of(context).size.width
        : width;
    final safeH = (height.isInfinite || height.isNaN) ? 200.0 : height;

    // What we actually fetch from the network (may be a cloudinary thumb)
    final fetchUrl = thumb
        ? cloudinaryThumb(imageUrl!, w: safeW.toInt(), h: safeH.toInt())
        : imageUrl!;

    // What we store/look up in the disk cache — always the ORIGINAL url.
    // This lets list thumbnails be reused by detail pages when offline.
    final key = imageUrl!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadiusValue),
      child: CachedNetworkImage(
        imageUrl:    getProxyImageUrl(fetchUrl),
        cacheKey:    key,
        width:       safeW,
        height:      safeH,
        fit:         BoxFit.cover,
        placeholder: (_, __) => _loading(safeW, safeH),
        errorWidget: (_, __, ___) => _broken(safeW, safeH),
      ),
    );
  }

  Widget _blank() => Container(
    width: width, height: height,
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(borderRadiusValue),
    ),
    child: const Center(child: Icon(Icons.image, color: Colors.grey)),
  );

  Widget _loading(double w, double h) => Container(
    width: w, height: h, color: Colors.grey[200],
    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
  );

  Widget _broken(double w, double h) => Container(
    width: w, height: h, color: Colors.grey[200],
    child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
  );
}