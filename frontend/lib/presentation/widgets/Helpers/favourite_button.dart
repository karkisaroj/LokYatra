import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../data/datasources/saved_remote_datasource.dart';

class _HomestayCache {
  _HomestayCache._();
  static final _HomestayCache instance = _HomestayCache._();

  final Map<int, ValueNotifier<bool>> _notifiers = {};
  final Set<int> _fetching = {};

  ValueNotifier<bool> notifierFor(int homestayId) =>
      _notifiers.putIfAbsent(homestayId, () => ValueNotifier(false));

  bool isLoaded(int homestayId) => _notifiers.containsKey(homestayId);

  Future<void> load(int homestayId) async {
    if (_fetching.contains(homestayId)) return;
    _fetching.add(homestayId);
    try {
      final resp = await SavedRemoteDatasource().checkSaved(homestayId);
      if (resp.statusCode == 200) {
        notifierFor(homestayId).value = resp.data['saved'] == true;
      }
    } catch (_) {
      notifierFor(homestayId);
    } finally {
      _fetching.remove(homestayId);
    }
  }

  Future<void> toggle(int homestayId) async {
    final notifier = notifierFor(homestayId);
    final prev = notifier.value;
    notifier.value = !prev; // optimistic
    try {
      final resp = await SavedRemoteDatasource().toggleSaved(homestayId);
      if (resp.statusCode == 200) {
        notifier.value = resp.data['saved'] == true;
      } else {
        notifier.value = prev; // revert
      }
    } catch (_) {
      notifier.value = prev; // revert
    }
  }

  void invalidate(int homestayId) => _notifiers.remove(homestayId);
  void invalidateAll() => _notifiers.clear();
}

class FavouriteButton extends StatefulWidget {
  final int homestayId;
  final double size;
  final bool showBackground;

  const FavouriteButton({
    super.key,
    required this.homestayId,
    this.size = 20,
    this.showBackground = true,
  });

  static void clearCache() => _HomestayCache.instance.invalidateAll();
  static Future<void> toggleHomestay(int homestayId) => _HomestayCache.instance.toggle(homestayId);

  @override
  State<FavouriteButton> createState() => _FavouriteButtonState();
}

class _FavouriteButtonState extends State<FavouriteButton>
    with SingleTickerProviderStateMixin {
  bool _loaded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1, end: 1.3).chain(
      CurveTween(curve: Curves.elasticOut),
    ).animate(_ctrl);
    _ensureLoaded();
  }

  @override
  void didUpdateWidget(covariant FavouriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.homestayId != widget.homestayId) {
      _loaded = false;
      _ensureLoaded();
    }
  }

  Future<void> _ensureLoaded() async {
    final cache = _HomestayCache.instance;
    if (cache.isLoaded(widget.homestayId)) {
      if (mounted) setState(() => _loaded = true);
      return;
    }
    await cache.load(widget.homestayId);
    if (mounted) setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleToggle(bool isCurrentlySaved) {
    _ctrl.forward(from: 0);
    _HomestayCache.instance.toggle(widget.homestayId);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return SizedBox(
        width: widget.showBackground ? 36.w : widget.size.w,
        height: widget.showBackground ? 36.h : widget.size.h,
        child: const Center(
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          ),
        ),
      );
    }

    return ValueListenableBuilder<bool>(
      valueListenable: _HomestayCache.instance.notifierFor(widget.homestayId),
      builder: (context, isSaved, child) {
        final icon = AnimatedBuilder(
          animation: _scale,
          builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
          child: Icon(
            isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: widget.size.sp,
            color: isSaved ? Colors.redAccent : Colors.grey[600],
          ),
        );

        if (!widget.showBackground) {
          return GestureDetector(onTap: () => _handleToggle(isSaved), child: icon);
        }

        return GestureDetector(
          onTap: () => _handleToggle(isSaved),
          child: Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08), blurRadius: 6)],
            ),
            child: Center(child: icon),
          ),
        );
      },
    );
  }
}