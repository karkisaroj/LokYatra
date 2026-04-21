import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lokyatra_frontend/core/services/constants.dart';

// ─── Cache ────────────────────────────────────────────────────────────────────
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

// ─── URL Helpers ──────────────────────────────────────────────────────────────

/// Parses a dynamic imageUrls field (String, List, JSON-encoded list)
/// and returns the first non-empty URL, or null.
String? getFirstImageUrl(dynamic imageUrls) {
  if (imageUrls == null) return null;

  if (imageUrls is String) {
    final s = imageUrls.trim();
    if (s.isEmpty || s == 'null') return null;

    if (s.startsWith('[') && s.endsWith(']')) {
      try {
        final List<dynamic> decoded = jsonDecode(s);
        return getFirstImageUrl(decoded);
      } catch (_) {}
    }

    if (s.contains(',')) {
      return getFirstImageUrl(s.split(','));
    }

    return s;
  }

  if (imageUrls is List && imageUrls.isNotEmpty) {
    for (var item in imageUrls) {
      final s = item?.toString().trim();
      if (s != null && s.isNotEmpty && s != 'null') return s;
    }
  }

  return null;
}

// ─── Proxy Image Widget ───────────────────────────────────────────────────────
/// Simple image widget. After migrating all images to Cloudinary, no proxy
/// is needed — Cloudinary handles CORS and CDN globally without issues.
class ProxyImage extends StatelessWidget {
  final String? imageUrl;
  final double  width;
  final double  height;
  final double  borderRadiusValue;
  final bool    thumb;       // kept for API compatibility, unused
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

  String _resolveUrl(String rawUrl) {
    var url = rawUrl.trim();
    if (url.isEmpty || url == 'null') return '';
    if (!url.startsWith('http')) {
      final path = url.startsWith('/') ? url : '/$url';
      url = '$imageBaseUrl$path';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final raw = imageUrl;
    if (raw == null || raw.isEmpty) return _blank();

    final safeW = (width.isInfinite  || width.isNaN)
        ? MediaQuery.of(context).size.width
        : width;
    final safeH = (height.isInfinite || height.isNaN)
        ? 200.0
        : height;

    final url = _resolveUrl(Uri.decodeFull(raw));
    if (url.isEmpty) return _blank();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadiusValue),
      child: kIsWeb
          ? _webImage(url, safeW, safeH)
          : _mobileImage(url, safeW, safeH),
    );
  }

  Widget _webImage(String url, double w, double h) {
    return Image.network(
      url,
      width:  w,
      height: h,
      fit:    fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _loading(w, h, progress: progress);
      },
      errorBuilder: (_, __, ___) => _broken(w, h),
    );
  }

  Widget _mobileImage(String url, double w, double h) {
    return CachedNetworkImage(
      imageUrl:        url,
      cacheKey:        overrideCacheKey ?? url,
      cacheManager:    LokYatraCacheManager(),
      width:           w,
      height:          h,
      fit:             fit,
      fadeInDuration:  const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
      placeholder:     (_, _) => _loading(w, h),
      errorWidget: (_, failedUrl, err) {
        debugPrint('[ProxyImage] failed: $failedUrl — $err');
        return _broken(w, h);
      },
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

  Widget _loading(double w, double h, {ImageChunkEvent? progress}) {
    double? value;
    if (progress != null && progress.expectedTotalBytes != null) {
      value = progress.cumulativeBytesLoaded / progress.expectedTotalBytes!;
    }
    return Container(
      width: w, height: h,
      color: Colors.grey[50],
      child: Center(
        child: SizedBox(
          width: 24, height: 24,
          child: CircularProgressIndicator(
            value: value, strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        ),
      ),
    );
  }

  Widget _broken(double w, double h) => Container(
    width: w, height: h,
    color: Colors.grey[50],
    child: Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey[300], size: 24)),
  );
}
