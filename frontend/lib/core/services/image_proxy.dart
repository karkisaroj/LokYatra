import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lokyatra_frontend/core/services/constants.dart';

// ── Custom cache manager: 30-day TTL, 500 images ─────────────────────────────
class LokYatraCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'lokyatraImageCache';

  static final LokYatraCacheManager _instance = LokYatraCacheManager._();
  factory LokYatraCacheManager() => _instance;

  LokYatraCacheManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: 500,
        ));
}

// ── Cloudinary URL helpers ────────────────────────────────────────────────────
String cloudinaryThumb(String url, {int w = 300, int h = 300}) {
  final idx = url.indexOf('/upload/');
  if (idx == -1) return url;
  final before = url.substring(0, idx + '/upload/'.length);
  final after  = url.substring(idx + '/upload/'.length);
  return '${before}c_fill,w_$w,h_$h,q_auto,f_auto/$after';
}

String cloudinaryFull(String url) => url;

String getProxyImageUrl(String originalUrl) =>
    '${apiBaseUrl}api/Sites/proxy-image?url=${Uri.encodeComponent(originalUrl)}';

String? getFirstImageUrl(dynamic imageUrls) {
  if (imageUrls is List && imageUrls.isNotEmpty) {
    final first = imageUrls.first?.toString();
    if (first != null && first.isNotEmpty) return first;
  }
  return null;
}

// ── ProxyImage widget ─────────────────────────────────────────────────────────
class ProxyImage extends StatelessWidget {
  final String? imageUrl;
  final double  width;
  final double  height;
  final double  borderRadiusValue;
  final bool    thumb;
  final String? overrideCacheKey;
  final BoxFit  fit;

  const ProxyImage({
    super.key,
    required this.imageUrl,
    this.width             = 60,
    this.height            = 60,
    this.borderRadiusValue = 8,
    this.thumb             = false,
    this.overrideCacheKey,
    this.fit               = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) return blank();

    final safeW = (width.isInfinite || width.isNaN)
        ? MediaQuery.of(context).size.width
        : width;
    final safeH = (height.isInfinite || height.isNaN) ? 200.0 : height;

    // Decode percent-encoded characters to avoid double-encoding by HTTP client
    // e.g. Wikimedia URLs with %2C, %27 in filenames
    final rawUrl = Uri.decodeFull(imageUrl!);
    final fetchUrl = thumb
        ? cloudinaryThumb(rawUrl, w: safeW.toInt(), h: safeH.toInt())
        : rawUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadiusValue),
      child: kIsWeb
          ? _webImage(fetchUrl, safeW, safeH)
          : _mobileImage(fetchUrl, safeW, safeH),
    );
  }

  // On web: use Image.network — flutter_cache_manager disk cache doesn't work
  // in a browser and causes silent failures for some images
  Widget _webImage(String url, double w, double h) {
    return Image.network(
      url,
      width:      w,
      height:     h,
      fit:        fit,
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : loading(w, h),
      errorBuilder: (context, error, stack) => broken(w, h),
    );
  }

  // On mobile: keep CachedNetworkImage with persistent disk cache
  Widget _mobileImage(String url, double w, double h) {
    final cacheKey = overrideCacheKey
        ?? (thumb ? 'thumb_$url' : 'full_$url');
    return CachedNetworkImage(
      imageUrl:          url,
      cacheKey:          cacheKey,
      cacheManager:      LokYatraCacheManager(),
      width:             w,
      height:            h,
      fit:               fit,
      maxWidthDiskCache: 1920,
      fadeInDuration:    const Duration(milliseconds: 200),
      fadeOutDuration:   const Duration(milliseconds: 100),
      placeholder:       (_, _) => loading(w, h),
      errorWidget:       (_, _, _) => broken(w, h),
    );
  }

  Widget blank() => Container(
    width: width, height: height,
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(borderRadiusValue),
    ),
    child: const Center(child: Icon(Icons.image, color: Colors.grey)),
  );

  Widget loading(double w, double h) => Container(
    width: w, height: h, color: Colors.grey[200],
    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
  );

  Widget broken(double w, double h) => Container(
    width: w, height: h, color: Colors.grey[200],
    child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
  );
}
