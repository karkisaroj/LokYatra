import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lokyatra_frontend/core/services/constants.dart';

// ── Sequential throttle for Wikimedia on mobile ───────────────────────────────
// Allows one new Wikimedia CDN request to start every 800 ms, preventing the
// burst of concurrent connections that triggers HTTP 429 from Wikimedia.
// Cached images skip the queue entirely (cache-check happens first in initState).
class _WikimediaThrottle {
  static final _WikimediaThrottle instance = _WikimediaThrottle._();
  _WikimediaThrottle._();
  Future<void> _gate = Future.value();

  Future<void> acquire() {
    final prev = _gate;
    final c = Completer<void>();
    // Next caller waits for c to complete, then another 800 ms before its turn.
    _gate = c.future.then((_) => Future.delayed(const Duration(milliseconds: 800)));
    // Our turn starts when prev resolves; immediately signal c so the chain advances.
    return prev.then((_) { c.complete(); });
  }
}

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

// Returns the Wikimedia CDN pre-rendered thumbnail URL (served by Fastly).
// We use a fixed 800 px width so the cache key is always the same URL,
// making the initState cache-check consistent with what CachedNetworkImage stores.
String wikimediaCdnThumb(String url) {
  const marker = 'upload.wikimedia.org/wikipedia/commons/';
  final idx = url.indexOf(marker);
  if (idx == -1 || url.contains('/commons/thumb/')) return url;
  final scheme   = url.startsWith('https') ? 'https' : 'http';
  final path     = url.substring(idx + marker.length); // "a/ad/File.jpg"
  final filename = path.split('/').last;                // "File.jpg"
  return '$scheme://${marker}thumb/$path/800px-$filename';
}

// Kept for legacy callers.
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
class ProxyImage extends StatefulWidget {
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
  State<ProxyImage> createState() => _ProxyImageState();
}

class _ProxyImageState extends State<ProxyImage> {
  static const _headers = {
    'User-Agent': 'LokYatraApp/1.0 (Flutter; heritage tourism FYP)',
  };

  late final Future<void> _ready;

  @override
  void initState() {
    super.initState();
    final raw = Uri.decodeFull(widget.imageUrl ?? '');

    if (!kIsWeb && _isWikimedia(raw)) {
      // Mobile Wikimedia: go through backend proxy (browser UA avoids 429).
      // Cache key = proxy URL so cache check and CachedNetworkImage agree.
      final proxyUrl = getProxyImageUrl(wikimediaCdnThumb(raw));
      final cacheKey = widget.overrideCacheKey ?? proxyUrl;
      _ready = LokYatraCacheManager()
          .getFileFromCache(cacheKey)
          .then((info) async {
        if (info != null) return; // already on disk — skip throttle
        await _WikimediaThrottle.instance.acquire(); // stagger proxy requests
      });
    } else {
      _ready = Future.value();
    }
  }

  // Resolve which URL to fetch.
  String _fetchUrl(String rawUrl) {
    if (_isCloudinary(rawUrl)) return rawUrl;
    // Mobile Wikimedia → backend proxy; web → CDN direct (browser UA is fine).
    if (_isWikimedia(rawUrl))  return kIsWeb ? wikimediaCdnThumb(rawUrl) : getProxyImageUrl(wikimediaCdnThumb(rawUrl));
    return getProxyImageUrl(rawUrl); // everything else via backend proxy
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) return _blank();

    final safeW = (widget.width.isInfinite  || widget.width.isNaN)
        ? MediaQuery.of(context).size.width
        : widget.width;
    final safeH = (widget.height.isInfinite || widget.height.isNaN)
        ? 200.0
        : widget.height;

    final rawUrl  = Uri.decodeFull(imageUrl);
    final fetchUrl = _fetchUrl(rawUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadiusValue),
      child: kIsWeb
          ? _webImage(fetchUrl, safeW, safeH)
          : _isWikimedia(rawUrl)
              // Wikimedia on mobile: wait for the stagger / cache-check future
              ? FutureBuilder<void>(
                  future: _ready,
                  builder: (_, snap) =>
                      snap.connectionState == ConnectionState.done
                          ? _mobileImage(fetchUrl, safeW, safeH)
                          : _loading(safeW, safeH),
                )
              : _mobileImage(fetchUrl, safeW, safeH),
    );
  }

  // ── renderers ───────────────────────────────────────────────────────────────

  Widget _webImage(String url, double w, double h) => Image.network(
    url,
    width:  w,
    height: h,
    fit:    widget.fit,
    // No custom headers on web: adding headers triggers a CORS preflight OPTIONS
    // request that Cloudinary and Wikimedia CDN reject, breaking image loads.
    // The browser sends its own User-Agent automatically, which Wikimedia accepts.
    loadingBuilder: (_, child, progress) =>
        progress == null ? child : _loading(w, h),
    errorBuilder: (_, __, ___) => _broken(w, h),
  );

  Widget _mobileImage(String url, double w, double h) =>
      CachedNetworkImage(
        imageUrl:        url,
        cacheKey:        widget.overrideCacheKey ?? url,
        cacheManager:    LokYatraCacheManager(),
        width:           w,
        height:          h,
        fit:             widget.fit,
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
    width: widget.width,
    height: widget.height,
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(widget.borderRadiusValue),
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
