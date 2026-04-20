import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lokyatra_frontend/core/services/constants.dart';

// ── Disk cache ────────────────────────────────────────────────────────────────
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

// ── URL helpers ───────────────────────────────────────────────────────────────

bool _isCloudinary(String url) => url.contains('cloudinary.com');
bool _isWikimedia(String url)  => url.contains('upload.wikimedia.org');

String wikimediaCdnThumb(String url) {
  const marker = 'upload.wikimedia.org/wikipedia/commons/';
  final idx = url.indexOf(marker);
  if (idx == -1 || url.contains('/commons/thumb/')) return url;
  final scheme   = url.startsWith('https') ? 'https' : 'http';
  final path     = url.substring(idx + marker.length);
  final filename = path.split('/').last;
  return '$scheme://${marker}thumb/$path/800px-$filename';
}

// Proxy for non-Cloudinary, non-Wikimedia images (backend Railway proxy).
String getProxyImageUrl(String originalUrl) =>
    '${apiBaseUrl}api/Sites/proxy-image?url=${Uri.encodeComponent(originalUrl)}';

String? getFirstImageUrl(dynamic imageUrls) {
  if (imageUrls is List && imageUrls.isNotEmpty) {
    final first = imageUrls.first?.toString();
    if (first != null && first.isNotEmpty) return first;
  }
  return null;
}

// images.weserv.nl is a free CDN proxy with whitelisted access to Wikimedia.
// It caches images on its own CDN so the phone never contacts Wikimedia directly.
// Use Dart's Uri class to properly encode the url= query parameter so filenames
// with special characters like apostrophes or parentheses are handled correctly.
String _weservUrl(String url) {
  final noScheme = url.replaceFirst(RegExp(r'^https?://'), '');
  return Uri(
    scheme: 'https',
    host: 'images.weserv.nl',
    queryParameters: {'url': noScheme},
  ).toString();
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

  // Resolve which URL to actually fetch.
  String _fetchUrl(String rawUrl) {
    if (_isCloudinary(rawUrl)) return rawUrl;
    if (_isWikimedia(rawUrl)) {
      final cdnThumb = wikimediaCdnThumb(rawUrl);
      // Web: browser UA is accepted by Wikimedia CDN directly.
      // Mobile: route through images.weserv.nl which has whitelisted CDN access
      //         to Wikimedia and caches the result — phone never contacts Wikimedia.
      return kIsWeb ? cdnThumb : _weservUrl(cdnThumb);
    }
    return getProxyImageUrl(rawUrl);
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

    final rawUrl   = Uri.decodeFull(imageUrl);
    final fetchUrl = _fetchUrl(rawUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadiusValue),
      child: kIsWeb
          ? _webImage(fetchUrl, safeW, safeH)
          : _mobileImage(fetchUrl, safeW, safeH),
    );
  }

  // ── renderers ───────────────────────────────────────────────────────────────

  // Providing any headers forces Flutter web into XHR/fetch mode so CanvasKit gets
  // the raw image bytes it needs to paint the canvas. Without headers, Flutter web
  // falls back to a native <img> element which CanvasKit cannot read (tainted canvas).
  // The User-Agent header is harmless: CORS preflight succeeds because Railway uses
  // AllowAnyHeader(), Cloudinary and Wikimedia CDN both return Access-Control-Allow-Origin: *.
  static const _webHeaders = {
    'User-Agent': 'LokYatraApp/1.0 (Flutter; heritage tourism FYP)',
  };

  Widget _webImage(String url, double w, double h) => Image.network(
    url,
    width:   w,
    height:  h,
    fit:     fit,
    headers: _webHeaders,
    loadingBuilder: (_, child, progress) =>
        progress == null ? child : _loading(w, h),
    errorBuilder: (_, __, ___) => _broken(w, h),
  );

  Widget _mobileImage(String url, double w, double h) =>
      CachedNetworkImage(
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

  // ── placeholders ────────────────────────────────────────────────────────────

  Widget _blank() => Container(
    width: width,
    height: height,
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
