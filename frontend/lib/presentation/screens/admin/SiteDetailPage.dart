import 'package:flutter/material.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';

class SiteDetailPage extends StatelessWidget {
  final Map<String, dynamic> site;
  const SiteDetailPage({super.key, required this.site});

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
    // Get all image URLs from the site data
    List<String> imageUrls = [];
    if (site['imageUrls'] != null && site['imageUrls'] is List) {
      for (var url in site['imageUrls']) {
        if (url != null && url.toString().isNotEmpty) {
          imageUrls.add(url.toString());
        }
      }
    }
    String? coverImage = imageUrls.isNotEmpty ? imageUrls.first : null;

    String name = (site['name'] ?? '').toString();
    String category = (site['category'] ?? '').toString();
    String district = (site['district'] ?? '').toString();
    String shortDescription = (site['shortDescription'] ?? '').toString();
    String historicalSignificance = (site['historicalSignificance'] ?? '').toString();
    String culturalImportance = (site['culturalImportance'] ?? '').toString();
    String openingTime = (site['openingTime'] ?? '—').toString();
    String closingTime = (site['closingTime'] ?? '—').toString();
    String entryFeeNPR = site['entryFeeNPR']?.toString() ?? '—';
    String entryFeeSAARC = site['entryFeeSAARC']?.toString() ?? '—';
    String bestTimeToVisit = (site['bestTimeToVisit'] ?? '—').toString();
    bool isUNESCO = site['isUNESCO'] == true;

    return Scaffold(
      appBar: AppBar(title: Text(name)),
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

          // Category, District, UNESCO chips
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (category.isNotEmpty) Chip(label: Text('Category: $category')),
            if (district.isNotEmpty) Chip(label: Text('District: $district')),
            if (isUNESCO) const Chip(label: Text('UNESCO')),
          ]),
          const SizedBox(height: 16),

          // Short description
          Text(shortDescription),
          const SizedBox(height: 12),

          // Historical significance
          if (historicalSignificance.isNotEmpty) ...[
            const Text('Historical Significance', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(historicalSignificance),
            const SizedBox(height: 12),
          ],

          // Cultural importance
          if (culturalImportance.isNotEmpty) ...[
            const Text('Cultural Importance', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(culturalImportance),
            const SizedBox(height: 12),
          ],

          const Divider(),
          const SizedBox(height: 8),

          // Visiting info
          const Text('Visiting Info', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Text('Opening: $openingTime')),
            Expanded(child: Text('Closing: $closingTime')),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: Text('Entry (NPR): $entryFeeNPR')),
            Expanded(child: Text('Entry SAARC: $entryFeeSAARC')),
          ]),
          const SizedBox(height: 6),
          Text('Best Time to Visit: $bestTimeToVisit'),
          const SizedBox(height: 12),

          // Dates
          Text('Created: ${formatDate(site['createdAt'])}'),
          Text('Updated: ${formatDate(site['updatedAt'])}'),
          const SizedBox(height: 16),

          // More photos
          if (imageUrls.length > 1) ...[
            const Text('More Photos', style: TextStyle(fontWeight: FontWeight.w600)),
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