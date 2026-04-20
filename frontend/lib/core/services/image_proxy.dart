import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lokyatra_frontend/core/services/constants.dart';

// Disk cache
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

// URL helpers
bool _isCloudinary(String url) => url.contains('cloudinary.com');
bool _isWikimedia(String url)  => url.contains('upload.wikimedia.org');

String wikimediaCdnThumb(String url) {
  const marker = 'upload.wikimedia.org/wikipedia/commons/';
  if (!url.contains(marker) || url.contains('/thumb/')) return url;

  final scheme   = url.startsWith('https') ? 'https' : 'http';
  try {
    final pathPart = url.substring(url.indexOf(marker) + marker.length);
    final parts    = pathPart.split('/');
    if (parts.length < 3) return url;
    
    final path     = '${parts[0]}/${parts[1]}';
    final filename = parts[2];
    
    final thumbUrl = '$scheme://${marker}thumb/$path/$filename/800px-$filename';
    return Uri.parse(thumbUrl).toString();
  } catch (e) {
    return url;
  }
}

// Backend proxy for images
String getProxyImageUrl(String originalUrl) {
  final base = imageBaseUrl;
  return '$base/api/Sites/proxy-image?url=${Uri.encodeComponent(originalUrl)}';
}

String? getFirstImageUrl(dynamic imageUrls) {
  if (imageUrls == null) return null;

  // 1. If it happens to be a string (sometimes raw JSON field or comma-separated)
  if (imageUrls is String) {
    final s = imageUrls.trim();
    if (s.isEmpty || s == 'null') return null;

    // Is it a JSON array string? e.g. '["url1", "url2"]'
    if (s.startsWith('[') && s.endsWith(']')) {
      try {
        final List<dynamic> decoded = jsonDecode(s);
        return getFirstImageUrl(decoded);
      } catch (_) {
        // Fall through to other checks
      }
    }

    // Is it comma separated? e.g. 'url1, url2'
    if (s.contains(',')) {
      final parts = s.split(',');
      return getFirstImageUrl(parts);
    }

    return s;
  }

  // 2. If it's a list
  if (imageUrls is List && imageUrls.isNotEmpty) {
    for (var item in imageUrls) {
      final s = item?.toString().trim();
      if (s != null && s.isNotEmpty && s != 'null') return s;
    }
  }

  return null;
}

// Main image loading logic
String _weservUrl(String url) {
  if (url.isEmpty) return url;
  // Use strings instead of Uri class for the outer part to avoid double-encoding issues
  // while ensuring the source url is properly encoded.
  return 'https://images.weserv.nl/?url=${Uri.encodeComponent(url)}&output=webp&we=1';
}

// ProxyImage widget
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

  // Resolve URL to absolute and apply proxy strategies
  String _resolveAbsolute(String rawUrl) {
    var url = rawUrl.trim();
    if (url.isEmpty || url == 'null') return '';

    // Handle relative paths or local filenames
    final bool wasRelative = !url.startsWith('http') && !url.startsWith('https');
    if (wasRelative) {
      final base = imageBaseUrl;
      final path = url.startsWith('/') ? url : '/$url';
      url = '$base$path';
    }
    return url;
  }

  String _fetchUrl(String rawUrl) {
    var url = _resolveAbsolute(rawUrl);
    if (url.isEmpty) return url;

    if (_isCloudinary(url)) return url;

    // Broad detection for local development and private networks
    final bool isLocal = url.contains('localhost') || 
                         url.contains('127.0.0.1') || 
                         url.contains('10.0.2.2') ||
                         url.contains('192.168.') ||
                         url.contains('172.') ||
                         url.contains('10.');

    if (_isWikimedia(url)) {
      final cdnThumb = wikimediaCdnThumb(url);
      // Wikimedia always needs proxying on Web/Mobile for consistency
      return _weservUrl(cdnThumb);
    }

    // Web proxy strategy
    if (kIsWeb) {
      if (isLocal || url.startsWith(imageBaseUrl)) return url;

      // Fallback for external images that might have CORS issues
      return _weservUrl(url);
    }

    // On mobile, if it's not local, proxying can provide better compression and reliability
    return isLocal ? url : _weservUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = this.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) return _blank();

    final safeW = (width.isInfinite  || width.isNaN)
        ? MediaQuery.of(context).size.width
        : width;
    final safeH = (height.isInfinite || height.isNaN)
        ? 200.0
        : height;

    final rawUrl     = Uri.decodeFull(imageUrl);
    final fetchUrl   = _fetchUrl(rawUrl);
    final absoluteSourceUrl = _resolveAbsolute(rawUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadiusValue),
      child: kIsWeb
          ? _webImage(fetchUrl, absoluteSourceUrl, safeW, safeH)
          : _mobileImage(fetchUrl, safeW, safeH),
    );
  }

  // Image renderers
  static const _webHeaders = {
    'Accept': 'image/avif,image/webp,image/*,*/*;q=0.8',
  };

  Widget _webImage(String url, String absoluteSourceUrl, double w, double h) {
    // If it's an SVG (and not already proxied by weserv), use SvgPicture
    if (url.toLowerCase().endsWith('.svg') && !url.contains('weserv.nl')) {
      return SvgPicture.network(
        url,
        width: w, height: h, fit: fit,
        placeholderBuilder: (_) => _loading(w, h),
      );
    }

    return Image.network(
      url,
      width:   w,
      height:  h,
      fit:     fit,
      headers: _webHeaders,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _loading(w, h, loadingProgress: loadingProgress);
      },
      errorBuilder: (_, __, ___) {
        // If initial load fails (CORS, 404, etc.), try the backend proxy as fallback
        if (!url.contains('proxy-image')) {
          return Image.network(
            getProxyImageUrl(absoluteSourceUrl),
            width: w, height: h, fit: fit,
            headers: _webHeaders,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _loading(w, h, loadingProgress: loadingProgress);
            },
            errorBuilder: (_, __, ___) => _broken(w, h),
          );
        }
        return _broken(w, h);
      },
    );
  }

  Widget _mobileImage(String url, double w, double h) {
    // If it's an SVG (and not already proxied by weserv), use SvgPicture
    if (url.toLowerCase().endsWith('.svg') && !url.contains('weserv.nl')) {
      return SvgPicture.network(
        url,
        width: w, height: h, fit: fit,
        placeholderBuilder: (_) => _loading(w, h),
      );
    }

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

  // Placeholders and status indicators
  Widget _blank() => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(borderRadiusValue),
    ),
    child: const Center(child: Icon(Icons.image, color: Colors.grey)),
  );

  Widget _loading(double w, double h, {ImageChunkEvent? loadingProgress}) {
    double? value;
    if (loadingProgress != null && loadingProgress.expectedTotalBytes != null) {
      value = loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!;
    }
    return Container(
      width: w, height: h,
      color: Colors.grey[50],
      child: Center(
        child: SizedBox(
          width: 24, height: 24,
          child: CircularProgressIndicator(
            value: value,
            strokeWidth: 2,
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
