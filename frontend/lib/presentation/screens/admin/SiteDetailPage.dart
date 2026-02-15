import 'package:flutter/material.dart';

class SiteDetailPage extends StatelessWidget {
  final Map<String, dynamic> site;
  const SiteDetailPage({super.key, required this.site});

  String _fmtTime(dynamic t) => (t == null || t.toString().isEmpty) ? '—' : t.toString(); // backend sends "HH:mm"
  String _fmtMoney(dynamic m) => m == null ? '—' : m.toString();
  String _fmtDate(dynamic d) {
    if (d == null) return '—';
    final dt = DateTime.tryParse(d.toString());
    if (dt == null) return d.toString();
    final local = dt.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final imgs = (site['imageUrls'] as List?)?.cast<String>() ?? const [];
    final cover = imgs.isNotEmpty ? imgs.first : null;

    return Scaffold(
      appBar: AppBar(title: Text((site['name'] ?? '').toString())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (cover != null)
            ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(cover, height: 220, fit: BoxFit.cover)),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if ((site['category'] ?? '').toString().isNotEmpty) Chip(label: Text('Category: ${site['category']}')),
            if ((site['district'] ?? '').toString().isNotEmpty) Chip(label: Text('District: ${site['district']}')),
            if (site['isUNESCO'] == true) const Chip(label: Text('UNESCO')),
          ]),
          const SizedBox(height: 16),
          Text((site['shortDescription'] ?? '').toString()),
          const SizedBox(height: 12),
          if ((site['historicalSignificance'] ?? '').toString().isNotEmpty) ...[
            const Text('Historical Significance', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text((site['historicalSignificance'] ?? '').toString()),
            const SizedBox(height: 12),
          ],
          if ((site['culturalImportance'] ?? '').toString().isNotEmpty) ...[
            const Text('Cultural Importance', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text((site['culturalImportance'] ?? '').toString()),
            const SizedBox(height: 12),
          ],
          const Divider(),
          const SizedBox(height: 8),
          const Text('Visiting Info', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Text('Opening: ${_fmtTime(site['openingTime'])}')),
            Expanded(child: Text('Closing: ${_fmtTime(site['closingTime'])}')),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: Text('Entry (NPR): ${_fmtMoney(site['entryFeeNPR'])}')),
            Expanded(child: Text('Entry SAARC: ${_fmtMoney(site['entryFeeSAARC'])}')),
          ]),
          const SizedBox(height: 6),
          Text('Best Time to Visit: ${(site['bestTimeToVisit'] ?? '—').toString()}'),
          const SizedBox(height: 12),
          Text('Created: ${_fmtDate(site['createdAt'])}'),
          Text('Updated: ${_fmtDate(site['updatedAt'])}'),
          const SizedBox(height: 16),
          if (imgs.length > 1) const Text('More Photos', style: TextStyle(fontWeight: FontWeight.w600)),
          if (imgs.length > 1)
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: imgs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(imgs[i], width: 180, height: 120, fit: BoxFit.cover),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}