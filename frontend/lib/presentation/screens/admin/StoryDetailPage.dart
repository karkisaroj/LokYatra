import 'package:flutter/material.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';

class StoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> story;
  const StoryDetailPage({super.key, required this.story});

  /// Formats a date string like "2026-02-15 10:30"
  String formatDate(dynamic date) {
    if (date == null) return '—';
    DateTime? parsed = DateTime.tryParse(date.toString());
    if (parsed == null) return date.toString();
    DateTime local = parsed.toLocal();
    String year = local.year.toString();
    String month = local.month.toString().padLeft(2, '0');
    String day = local.day.toString().padLeft(2, '0');
    String hour = local.hour.toString().padLeft(2, '0');
    String minute = local.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    // Get all image URLs from the story data
    List<String> imageUrls = [];
    if (story['imageUrls'] != null && story['imageUrls'] is List) {
      for (var url in story['imageUrls']) {
        if (url != null && url.toString().isNotEmpty) {
          imageUrls.add(url.toString());
        }
      }
    }
    String? coverImage = imageUrls.isNotEmpty ? imageUrls.first : null;

    String title = (story['title'] ?? '').toString();
    String storyType = (story['storyType'] ?? '').toString();
    int readTime = story['estimatedReadTimeMinutes'] ?? 0;
    String fullContent = (story['fullContent'] ?? '').toString();
    String historicalContext = (story['historicalContext'] ?? '').toString();
    String culturalSignificance = (story['culturalSignificance'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cover image
          if (coverImage != null)
            ProxyImage(
              imageUrl: coverImage,
              width: double.infinity,
              height: 220,
              borderRadiusValue: 12,
            ),
          const SizedBox(height: 16),

          // Type and read time chips
          Wrap(spacing: 8, runSpacing: 8, children: [
            Chip(label: Text('Type: $storyType')),
            Chip(label: Text('Read: $readTime min')),
          ]),
          const SizedBox(height: 12),

          // Full story content
          const Text('Story', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(fullContent),
          const SizedBox(height: 12),

          // Historical context
          if (historicalContext.isNotEmpty) ...[
            const Text('Historical Context', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(historicalContext),
            const SizedBox(height: 12),
          ],

          // Cultural significance
          if (culturalSignificance.isNotEmpty) ...[
            const Text('Cultural Significance', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(culturalSignificance),
            const SizedBox(height: 12),
          ],

          // Dates
          Text('Created: ${formatDate(story['createdAt'])}'),
          Text('Updated: ${formatDate(story['updatedAt'])}'),
          const SizedBox(height: 16),

          // More images
          if (imageUrls.length > 1) ...[
            const Text('More Images', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  return ProxyImage(
                    imageUrl: imageUrls[index],
                    width: 180,
                    height: 120,
                    borderRadiusValue: 8,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}