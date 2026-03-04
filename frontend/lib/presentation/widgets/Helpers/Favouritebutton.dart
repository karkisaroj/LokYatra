import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../data/datasources/saved_remote_datasource.dart';

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

  @override
  State<FavouriteButton> createState() => _FavouriteButtonState();
}

class _FavouriteButtonState extends State<FavouriteButton>
    with SingleTickerProviderStateMixin {
  bool _isSaved = false;
  bool _loading = true;
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  final _ds = SavedRemoteDatasource();

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
    _checkSaved();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _checkSaved() async {
    try {
      final resp = await _ds.checkSaved(widget.homestayId);
      if (resp.statusCode == 200 && mounted) {
        setState(() {
          _isSaved = resp.data['saved'] as bool? ?? false;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle() async {
    if (_loading) return;

    // Optimistic update
    setState(() => _isSaved = !_isSaved);
    _ctrl.forward(from: 0);

    try {
      final resp = await _ds.toggleSaved(widget.homestayId);
      if (resp.statusCode == 200 && mounted) {
        setState(() {
          _isSaved = resp.data['saved'] as bool? ?? _isSaved;
        });
      }
    } catch (_) {
      // Revert on error
      if (mounted) setState(() => _isSaved = !_isSaved);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
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

    final icon = AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: Icon(
        _isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        size: widget.size.sp,
        color: _isSaved ? Colors.redAccent : Colors.grey[600],
      ),
    );

    if (!widget.showBackground) {
      return GestureDetector(onTap: _toggle, child: icon);
    }

    return GestureDetector(
      onTap: _toggle,
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
  }
}