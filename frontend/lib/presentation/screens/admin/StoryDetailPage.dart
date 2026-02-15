import 'package:flutter/material.dart';

class StoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> story;
  const StoryDetailPage({super.key, required this.story});

  String _fmtDate(dynamic d) {
    if (d == null) return '—';
    final dt = DateTime.tryParse(d.toString());
    if (dt == null) return d.toString();
    final local = dt.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final imgs = (story['imageUrls'] as List?)?.cast<String>() ?? const [];
    final cover = imgs.isNotEmpty ? imgs.first : null;

    return Scaffold(
      appBar: AppBar(title: Text((story['title'] ?? '').toString())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (cover != null)
            ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(cover, height: 220, fit: BoxFit.cover)),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            Chip(label: Text('Type: ${(story['storyType'] ?? '').toString()}')),
            Chip(label: Text('Read: ${(story['estimatedReadTimeMinutes'] ?? 0)} min')),
          ]),
          const SizedBox(height: 12),
          const Text('Story', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text((story['fullContent'] ?? '').toString()),
          const SizedBox(height: 12),
          if ((story['historicalContext'] ?? '').toString().isNotEmpty) ...[
            const Text('Historical Context', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text((story['historicalContext'] ?? '').toString()),
            const SizedBox(height: 12),
          ],
          if ((story['culturalSignificance'] ?? '').toString().isNotEmpty) ...[
            const Text('Cultural Significance', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text((story['culturalSignificance'] ?? '').toString()),
            const SizedBox(height: 12),
          ],
          Text('Created: ${_fmtDate(story['createdAt'])}'),
          Text('Updated: ${_fmtDate(story['updatedAt'])}'),
          const SizedBox(height: 16),
          if (imgs.length > 1) const Text('More Images', style: TextStyle(fontWeight: FontWeight.w600)),
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