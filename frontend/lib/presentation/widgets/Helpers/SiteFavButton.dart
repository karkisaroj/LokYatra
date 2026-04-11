import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/datasources/saved_sites_remote_datasource.dart';

/// Standalone heart-toggle button for heritage sites.
/// Loads its own saved status and uses optimistic UI — no spinner.
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

  @override
  State<SiteFavButton> createState() => _SiteFavButtonState();
}

class _SiteFavButtonState extends State<SiteFavButton> {
  bool _isSaved = false;
  bool _loaded  = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      final resp = await SavedSitesRemoteDatasource().checkSaved(widget.siteId);
      if (resp.statusCode == 200 && mounted) {
        setState(() {
          _isSaved = resp.data['saved'] == true;
          _loaded  = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  Future<void> _toggle() async {
    final prev = _isSaved;
    // Optimistic update — instant feedback
    setState(() => _isSaved = !_isSaved);
    try {
      final resp = await SavedSitesRemoteDatasource().toggleSaved(widget.siteId);
      if (resp.statusCode == 200 && mounted) {
        setState(() => _isSaved = resp.data['saved'] == true);
      } else if (mounted) {
        setState(() => _isSaved = prev); // revert on unexpected response
      }
    } catch (_) {
      if (mounted) setState(() => _isSaved = prev); // revert on error
    }
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
    return GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: Icon(
        _isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        size: widget.size.sp,
        color: _isSaved ? widget.activeColor : Colors.grey[400],
      ),
    );
  }
}
