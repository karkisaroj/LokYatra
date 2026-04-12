import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/datasources/saved_sites_remote_datasource.dart';

/// Shared in-memory cache: siteId → saved state.
/// All SiteFavButton instances listen to this so they update together.
class _SiteCache {
  _SiteCache._();
  static final _SiteCache instance = _SiteCache._();

  final Map<int, ValueNotifier<bool>> _notifiers = {};
  final Set<int> _fetching = {};

  ValueNotifier<bool> notifierFor(int siteId) =>
      _notifiers.putIfAbsent(siteId, () => ValueNotifier(false));

  bool isLoaded(int siteId) => _notifiers.containsKey(siteId);

  Future<void> load(int siteId) async {
    if (_fetching.contains(siteId)) return;
    _fetching.add(siteId);
    try {
      final resp = await SavedSitesRemoteDatasource().checkSaved(siteId);
      if (resp.statusCode == 200) {
        notifierFor(siteId).value = resp.data['saved'] == true;
      }
    } catch (_) {
      notifierFor(siteId); // ensure notifier exists so isLoaded returns true
    } finally {
      _fetching.remove(siteId);
    }
  }

  Future<void> toggle(int siteId) async {
    final notifier = notifierFor(siteId);
    final prev = notifier.value;
    notifier.value = !prev; // optimistic
    try {
      final resp = await SavedSitesRemoteDatasource().toggleSaved(siteId);
      if (resp.statusCode == 200) {
        notifier.value = resp.data['saved'] == true;
      } else {
        notifier.value = prev; // revert
      }
    } catch (_) {
      notifier.value = prev; // revert
    }
  }

  void invalidate(int siteId) => _notifiers.remove(siteId);
  void invalidateAll() => _notifiers.clear();
}

class SiteFavButton extends StatefulWidget {
  final int siteId;
  final double size;
  final Color activeColor;

  const SiteFavButton({
    super.key,
    required this.siteId,
    this.size = 20,
    this.activeColor = Colors.redAccent,
  });

  /// Call this when the user logs out to clear cached states.
  static void clearCache() => _SiteCache.instance.invalidateAll();

  @override
  State<SiteFavButton> createState() => _SiteFavButtonState();
}

class _SiteFavButtonState extends State<SiteFavButton> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _ensureLoaded();
  }

  Future<void> _ensureLoaded() async {
    final cache = _SiteCache.instance;
    if (cache.isLoaded(widget.siteId)) {
      if (mounted) setState(() => _loaded = true);
      return;
    }
    await cache.load(widget.siteId);
    if (mounted) setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return SizedBox(
        width: widget.size.w,
        height: widget.size.w,
        child: Icon(Icons.favorite_border_rounded,
            size: widget.size.sp, color: Colors.grey[400]),
      );
    }

    return ValueListenableBuilder<bool>(
      valueListenable: _SiteCache.instance.notifierFor(widget.siteId),
      builder: (_, isSaved, __) {
        return GestureDetector(
          onTap: () => _SiteCache.instance.toggle(widget.siteId),
          behavior: HitTestBehavior.opaque,
          child: Icon(
            isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: widget.size.sp,
            color: isSaved ? widget.activeColor : Colors.grey[400],
          ),
        );
      },
    );
  }
}
